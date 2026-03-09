#!/bin/bash

# 获取当前目录
CURRENT_DIR=$(pwd)

# 显示主菜单
show_menu() {
    echo ""
    echo "================================"
    echo "       Git 操作菜单"
    echo "================================"
    echo "1. 创建仓库"
    echo "2. 提交代码"
    echo "3. 回退版本"
    echo "4. 拉取仓库"
    echo "0. 退出"
    echo "================================"
    echo -n "请选择操作 [0-4]: "
}

# 选项1: 创建仓库
create_repo() {
    echo ""
    echo "--- 创建仓库 ---"
    echo -n "请输入仓库名 (例如: shift8869/WHMES.git): "
    read repo_name

    if [ -z "$repo_name" ]; then
        echo "未输入仓库名，返回主菜单"
        return
    fi

    echo ""
    echo "开始初始化仓库..."

    git config --global --add safe.directory "$CURRENT_DIR"
    git init
    git add .
    git commit -m "first commit"
    git branch -M main
    git remote add origin "https://github.com/$repo_name"
    git push -u origin main

    echo ""
    echo "仓库创建完成！"
}

# 选项2: 提交代码
commit_code() {
    echo ""
    echo "--- 提交代码 ---"
    echo -n "请输入更新说明: "
    read commit_msg

    if [ -z "$commit_msg" ]; then
        echo "未输入更新说明，返回主菜单"
        return
    fi

    echo ""
    echo "开始提交代码..."

    git add .
    git commit -m "$commit_msg"
    git push

    echo ""
    echo "代码提交完成！"
}

# 选项3: 回退版本
rollback_version() {
    echo ""
    echo "--- 回退版本 ---"
    echo "最近10条提交记录："
    echo ""

    # 获取最近10条提交记录
    mapfile -t commits < <(git log --oneline -10)

    if [ ${#commits[@]} -eq 0 ]; then
        echo "没有找到提交记录"
        return
    fi

    # 显示带序号的提交记录
    for i in "${!commits[@]}"; do
        echo "$((i+1)). ${commits[$i]}"
    done

    echo ""
    echo -n "请选择要回退的版本序号 (1-${#commits[@]}): "
    read choice

    if [ -z "$choice" ]; then
        echo "未选择版本，返回主菜单"
        return
    fi

    # 验证输入是否为数字且在范围内
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#commits[@]} ]; then
        echo "无效的选择，返回主菜单"
        return
    fi

    # 获取选中的提交哈希
    selected_commit="${commits[$((choice-1))]}"
    commit_hash=$(echo "$selected_commit" | awk '{print $1}')

    echo ""
    echo "选中的版本: $selected_commit"
    echo ""
    echo -n "确认强制回退到该版本吗？(输入 Y 确认，其他键取消): "
    read confirm

    if [ "$confirm" != "Y" ] && [ "$confirm" != "y" ]; then
        echo "取消回退，返回主菜单"
        return
    fi

    echo ""
    echo "开始回退版本..."

    git reset --hard "$commit_hash"
    git push -f

    echo ""
    echo "版本回退完成！"
}

# 选项4: 拉取仓库
pull_repo() {
    echo ""
    echo "--- 拉取仓库 ---"
    echo -n "请输入仓库名 (例如: shift8869/WHMES.git): "
    read repo_name

    if [ -z "$repo_name" ]; then
        echo "未输入仓库名，返回主菜单"
        return
    fi

    echo ""
    echo "开始克隆仓库..."

    git clone "https://github.com/$repo_name" .

    echo ""
    echo "仓库拉取完成！"
}

# 主循环
main() {
    while true; do
        show_menu
        read choice

        case $choice in
            1)
                create_repo
                ;;
            2)
                commit_code
                ;;
            3)
                rollback_version
                ;;
            4)
                pull_repo
                ;;
            0)
                echo ""
                echo "退出程序，再见！"
                exit 0
                ;;
            *)
                echo ""
                echo "无效的选择，请重新输入"
                ;;
        esac
    done
}

# 启动程序
echo "当前工作目录: $CURRENT_DIR"
main
