# 数据库备份（sql/backup）

本目录存放**本机数据库的完整备份**，用于快速回到某个可用基线。

## 文件说明

| 文件 | 说明 |
| --- | --- |
| `poyang_crab_full_<时间戳>.sql` | `mysqldump` 全量导出（结构 + 数据，含 43 张表） |

> 备份由 `mysqldump` 生成，包含建表语句与数据；**不含** `CREATE DATABASE`（还原前需先建库）。

## 生成备份

```powershell
# 方式一：直接调用 mysqldump（推荐，--result-file 避免 PowerShell 重定向写出 UTF-16）
& 'D:\BtSoft\mysql\MySQL8.0\bin\mysqldump.exe' --default-character-set=utf8mb4 `
  -upoyang_crab -p'BZcEXmWxiDcmx5bw' --single-transaction --skip-lock-tables `
  --routines --triggers --events --hex-blob --no-tablespaces --set-gtid-purged=OFF `
  --result-file="D:\ai\xiegongzhu.com\sql\backup\poyang_crab_full_$(Get-Date -Format 'yyyyMMdd-HHmmss').sql" `
  poyang_crab
```

## 还原备份

```powershell
# 1) 先建库（若已存在可跳过）
& 'D:\BtSoft\mysql\MySQL8.0\bin\mysql.exe' -upoyang_crab -p'BZcEXmWxiDcmx5bw' -e "CREATE DATABASE IF NOT EXISTS poyang_crab DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"

# 2) 还原（注意用 source 方式，避免 PowerShell 管道编码问题）
& 'D:\BtSoft\mysql\MySQL8.0\bin\mysql.exe' -upoyang_crab -p'BZcEXmWxiDcmx5bw' -e "source D:/ai/xiegongzhu.com/sql/backup/poyang_crab_full_<时间戳>.sql"

# 3) 校验
& 'D:\BtSoft\mysql\MySQL8.0\bin\mysql.exe' -upoyang_crab -p'BZcEXmWxiDcmx5bw' -N -e "select count(*) from information_schema.tables where table_schema='poyang_crab';"
```

## 说明

- 结构基线仍是 `sql/00_schema.sql ~ 99_init_data.sql`（可重复执行、幂等）；本目录的备份是**带数据的快照**，两者不冲突。
- 备份内含演示会员手机号、后台账号口令哈希等数据，请勿把 `sql/backup/` 内容发布到公开仓库。
