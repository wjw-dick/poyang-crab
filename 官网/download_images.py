# -*- coding: utf-8 -*-
import urllib.request
import os

base = r"D:\ai\xiegongzhu.com\官网\assets"
os.makedirs(base, exist_ok=True)

imgs = {
    "hero_crab.jpg": "https://aka.doubaocdn.com/s/81DVbwjFx4",   # 手托大闸蟹·养殖塘背景
    "fresh_crabs.jpg": "https://aka.doubaocdn.com/s/ipPIGzPVvP", # 泡沫箱鲜活蟹
    "steamed_crab.jpg": "https://aka.doubaocdn.com/s/AZw5jNINCF",# 蒸熟橘红蟹
    "poyang_lake.jpg": "https://aka.doubaocdn.com/s/ECvXw6X2Us", # 鄱阳湖湿地航拍
}

for name, url in imgs.items():
    path = os.path.join(base, name)
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req, timeout=30) as r, open(path, "wb") as f:
            f.write(r.read())
        print("OK  ", name, os.path.getsize(path))
    except Exception as e:
        print("FAIL", name, repr(e))
