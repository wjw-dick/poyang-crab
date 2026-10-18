#!/bin/bash
# =============================================================
# T04 每日全量备份：mysqldump + gzip，保留最近 14 份
# 由 docker-compose 的 mysql-backup 服务每 24h 调用一次
# 手动执行：docker exec crab-mysql-backup /usr/local/bin/backup-mysql.sh
# =============================================================
set -euo pipefail

MYSQL_HOST="${MYSQL_HOST:-mysql8}"
MYSQL_USER="${MYSQL_USER:-root}"
MYSQL_DATABASE="${MYSQL_DATABASE:-poyang_crab}"
BACKUP_KEEP="${BACKUP_KEEP:-14}"
BACKUP_DIR="${BACKUP_DIR:-/backup}"

STAMP="$(date +%Y%m%d_%H%M%S)"
FILE="${BACKUP_DIR}/${MYSQL_DATABASE}_${STAMP}.sql.gz"

mkdir -p "${BACKUP_DIR}"

echo "[backup] $(date '+%F %T') 开始全量备份 ${MYSQL_DATABASE} -> ${FILE}"

# 全量备份：表结构与数据 + 触发器/存储过程 + 一致性快照
mysqldump \
  --host="${MYSQL_HOST}" \
  --user="${MYSQL_USER}" \
  --single-transaction \
  --quick \
  --routines \
  --triggers \
  --events \
  --default-character-set=utf8mb4 \
  --set-gtid-purged=OFF \
  "${MYSQL_DATABASE}" | gzip -9 > "${FILE}"

SIZE="$(du -h "${FILE}" | cut -f1)"
echo "[backup] 备份完成 ${FILE} (${SIZE})"

# 保留策略：仅保留最近 BACKUP_KEEP 份（默认 14 份）
ls -1t "${BACKUP_DIR}"/"${MYSQL_DATABASE}"_*.sql.gz 2>/dev/null | tail -n +$((BACKUP_KEEP + 1)) | while read -r old; do
  echo "[backup] 清理过期备份 ${old}"
  rm -f "${old}"
done

echo "[backup] 当前保留 $(ls -1 "${BACKUP_DIR}"/"${MYSQL_DATABASE}"_*.sql.gz 2>/dev/null | wc -l) 份"

# -------------------------------------------------------------
# 恢复演练（T31）：
#   gunzip -c /backup/poyang_crab_YYYYmmdd_HHMMSS.sql.gz | \
#     mysql -h mysql8 -uroot -p poyang_crab_restore_test
# -------------------------------------------------------------
