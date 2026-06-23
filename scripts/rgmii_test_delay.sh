#!/bin/bash
# rgmii_delay_test.sh - 矩阵扫描并保存结果

INTERFACE="eth0"
SYSFS_PATH="/sys/devices/platform/fe2a0000.ethernet/rgmii_delayline"
MIN_DELAY=0
MAX_DELAY=127      # 0x7f
STEP=5             # 0x5
PEER_IP="192.168.2.1"  # 对端设备IP

[ $# -eq 1 ] && PEER_IP=$1

# 检查接口
if [ ! -e "$SYSFS_PATH" ]; then
    echo "错误: 找不到 $SYSFS_PATH"
    exit 1
fi

# 保存原始设置
ORIGINAL_DELAY=40 55

# 准备输出文件
OUTPUT_FILE="./rgmii_delay_matrix_$(date +%Y%m%d_%H%M%S).txt"
echo "RGMII延迟测试矩阵" > "$OUTPUT_FILE"
echo "原始设置: $ORIGINAL_DELAY" >> "$OUTPUT_FILE"
echo "测试范围: TX=0x00-0x7f, RX=0x00-0x7f, 步进=0x5" >> "$OUTPUT_FILE"
echo "对端IP: $PEER_IP" >> "$OUTPUT_FILE"
echo "测试时间: $(date)" >> "$OUTPUT_FILE"
echo "=" * 80 >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 打印RX表头
echo "RX延迟" >> "$OUTPUT_FILE"
printf "TX/RX " >> "$OUTPUT_FILE"
for ((rx=MIN_DELAY; rx<=MAX_DELAY; rx+=STEP)); do
    printf "%02x " $rx >> "$OUTPUT_FILE"
done
echo >> "$OUTPUT_FILE"

echo "-----"$(printf "%0.s-" {1..78}) >> "$OUTPUT_FILE"

# 主扫描循环
for ((tx=MIN_DELAY; tx<=MAX_DELAY; tx+=STEP)); do
    printf "0x%02x | " $tx >> "$OUTPUT_FILE"
    
    # 实时显示进度
    printf "\r测试进度: TX=0x%02x (%d/%d)" $tx $tx $MAX_DELAY
    
    for ((rx=MIN_DELAY; rx<=MAX_DELAY; rx+=STEP)); do
        # 设置延迟
        echo "$tx $rx" > "$SYSFS_PATH"
        sleep 0.2  # 稍微降低等待时间
        
        # 测试连通性
        if ping -s 1400 -c 1 -W 1 $PEER_IP &> /dev/null; then
            printf "O" >> "$OUTPUT_FILE"
        elif ethtool eth0 >/dev/null | grep -q "Link detected: yes"; then
            printf "." >> "$OUTPUT_FILE"
        else
            printf " " >> "$OUTPUT_FILE"
        fi
        
        printf "  " >> "$OUTPUT_FILE"
    done
    
    echo >> "$OUTPUT_FILE"
done

# 恢复原始设置
echo "$ORIGINAL_DELAY" > "$SYSFS_PATH"

# 添加图例和总结
echo "" >> "$OUTPUT_FILE"
echo "-----"$(printf "%0.s-" {1..78}) >> "$OUTPUT_FILE"
echo "图例: O=成功(ping通), .=链路正常(ping不通), 空格=链路断开" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 简单的成功计数
SUCCESS_COUNT=$(grep -o 'O' "$OUTPUT_FILE" | wc -l)
TOTAL_COUNT=$(( ((MAX_DELAY - MIN_DELAY) / STEP + 1) ** 2 ))
echo "成功组合: $SUCCESS_COUNT/$TOTAL_COUNT" >> "$OUTPUT_FILE"

echo ""
echo "扫描完成!"
echo "结果已保存到: $OUTPUT_FILE"
echo "原始设置已恢复: $ORIGINAL_DELAY"
