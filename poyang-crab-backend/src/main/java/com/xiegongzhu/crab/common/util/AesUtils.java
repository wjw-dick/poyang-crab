package com.xiegongzhu.crab.common.util;

import com.xiegongzhu.crab.common.exception.BizException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.Arrays;
import java.util.Base64;

/**
 * PRO.md 6.2：密钥加密不明文落库（对象存储 AK/SK、微信 Secret、支付密钥）
 * AES-256-GCM，随机 IV 前置，输出 Base64。
 */
@Component
public class AesUtils {

    private static final int IV_LENGTH = 12;
    private static final int TAG_LENGTH_BIT = 128;
    private static final String ALGORITHM = "AES/GCM/NoPadding";

    private final SecretKeySpec keySpec;

    public AesUtils(@Value("${crab.jwt.secret}") String secret) {
        // 取 MD5 长度外的原始字节并补齐 32 字节，作为 AES-256 密钥
        byte[] raw = secret.getBytes(StandardCharsets.UTF_8);
        byte[] key = Arrays.copyOf(raw, 32);
        this.keySpec = new SecretKeySpec(key, "AES");
    }

    public String encrypt(String plainText) {
        if (plainText == null || plainText.isEmpty()) {
            return plainText;
        }
        try {
            byte[] iv = new byte[IV_LENGTH];
            new SecureRandom().nextBytes(iv);
            Cipher cipher = Cipher.getInstance(ALGORITHM);
            cipher.init(Cipher.ENCRYPT_MODE, keySpec, new GCMParameterSpec(TAG_LENGTH_BIT, iv));
            byte[] cipherText = cipher.doFinal(plainText.getBytes(StandardCharsets.UTF_8));

            byte[] merged = new byte[iv.length + cipherText.length];
            System.arraycopy(iv, 0, merged, 0, iv.length);
            System.arraycopy(cipherText, 0, merged, iv.length, cipherText.length);
            return Base64.getEncoder().encodeToString(merged);
        } catch (Exception e) {
            throw new BizException("加密失败：" + e.getMessage());
        }
    }

    public String decrypt(String cipherText) {
        if (cipherText == null || cipherText.isEmpty()) {
            return cipherText;
        }
        try {
            byte[] merged = Base64.getDecoder().decode(cipherText);
            byte[] iv = Arrays.copyOfRange(merged, 0, IV_LENGTH);
            byte[] data = Arrays.copyOfRange(merged, IV_LENGTH, merged.length);
            Cipher cipher = Cipher.getInstance(ALGORITHM);
            cipher.init(Cipher.DECRYPT_MODE, keySpec, new GCMParameterSpec(TAG_LENGTH_BIT, iv));
            return new String(cipher.doFinal(data), StandardCharsets.UTF_8);
        } catch (Exception e) {
            throw new BizException("解密失败：" + e.getMessage());
        }
    }

    /** 脱敏展示：AK/SK 回显时只显示尾 4 位 */
    public String mask(String plainText) {
        if (plainText == null || plainText.length() <= 4) {
            return "****";
        }
        return "****" + plainText.substring(plainText.length() - 4);
    }
}
