#!/bin/bash

# 生成文件列表页面的shell脚本
generate_file_list_page() {
    # 文件头
    cat << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>package列表</title>
</head>
<body>
    <h1>package文件列表</h1>
    <ul style="wdith:100%;font-size:14px;>
EOF

    # 中间部分：遍历当前目录所有文件
    for file in *; do
        if [ -f "$file" ]; then
            echo "        <li><a href=\"$file\">$file</a></li>"
        fi
    done

    # 文件尾
    cat << 'EOF'
    </ul>
<ul style="color:#fff;font-size:10px; background-color:#cccccc;width:100%;">
<li>本站内容仅供个人使用</li>
<li>本人不对任何人因使用本固件所遭受的任何理论或实际的损失承担责任！</li>
<li>本站资源禁止用于任何商业用途和非法用途，请务必严格遵守国家互联网使用相关法律规定！</li>
</ul>
</body>
</html>
EOF
}

# 主函数
main() {
    # 调用生成函数
    generate_file_list_page
    return $?
}

# 执行主函数
main