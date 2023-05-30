#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"
file_path="/etc/opencloud"
do_region='{"opencloud":[{"name":"New York 1（美国纽约）","id":"nyc1"},{"name":"San Francisco 1（美国旧金山）","id":"sfo1"},{"name":"Singapore 1（新加坡）","id":"sgp1"},{"name":"London 1（英国伦敦）","id":"lon1"},{"name":"New York 3（美国纽约）","id":"fra1"},{"name":"Amsterdam 3（荷兰）","id":"ams3"},{"name":"Frankfurt 1（德国）","id":"fra1"},{"name":"Toronto 1（加拿大）","id":"tor1"},{"name":"Bangalore 1（印度）","id":"blr1"},{"name":"San Francisco 3（美国旧金山）","id":"sfo3"}]}'
do_image='{"opencloud":[{"name":"centos-7-x64","id":"centos-7-x64"},{"name":"centos-stream-8-x64","id":"centos-stream-8-x64"},{"name":"centos-stream-9-x64","id":"centos-stream-9-x64"},{"name":"debian-10-x64","id":"debian-10-x64"},{"name":"debian-11-x64","id":"debian-11-x64"},{"name":"ubuntu-18-04-x64","id":"ubuntu-18-04-x64"},{"name":"ubuntu-20-04-x64","id":"ubuntu-20-04-x64"},{"name":"ubuntu-22-04-x64","id":"ubuntu-22-04-x64"}]}'
do_size='{"opencloud":[{"name":"1Vcpu(Regular) 1GB 1TB $6.00","id":"s-1vcpu-1gb"},{"name":"1Vcpu(Regular) 2GB 2TB $12.00","id":"s-1vcpu-2gb"},{"name":"2Vcpu(Regular) 2GB 3TB $18.00","id":"s-2vcpu-2gb"},{"name":"2Vcpu(Regular) 4GB 4TB $24.00","id":"s-2vcpu-4gb"},{"name":"1Vcpu(amd) 1GB 1TB $7.00","id":"s-1vcpu-1gb-amd"},{"name":"1Vcpu(amd) 2GB 2TB $14.00","id":"s-1vcpu-2gb-amd"},{"name":"2Vcpu(amd) 2GB 3TB $21.00","id":"s-2vcpu-2gb-amd"},{"name":"2Vcpu(amd) 2GB 4TB $28.00","id":"s-2vcpu-4gb-amd"},{"name":"1Vcpu(intel) 1GB 1TB $7.00","id":"s-1vcpu-1gb-intel"},{"name":"1Vcpu(intel) 2GB 2TB $14.00","id":"s-1vcpu-2gb-intel"},{"name":"2Vcpu 2GB 3TB $21.00","id":"s-2vcpu(intel)-2gb-intel"},{"name":"2Vcpu(intel) 4GB 4TB $28.00","id":"s-2vcpu-4gb-intel"}]}'

#do删除vm
do_vm_del(){
	clear
	echo -e "`date` 正在进行 ${submodule} 删除VM操作\n"
	
	mapfile -t api_data_array < "$file_path/$submodule/api"

	if [ ${#api_data_array[@]} -eq 0 ]; then
		clear
		echo -e "`date` 正在进行 ${submodule} 查询API操\n\n当前API文件内无保存任何秘钥，请先添加API。"
		
		read -s -n 1 -p "按下回车键将返回 ${submodule} 菜单，输入'q'退出"
		
		if [[ $REPLY == "" ]]; then
			${submodule}_memu
		else
			exit 1
		fi
	fi

		echo -e "\n已保存的信息：\n编号 | API名字 | API地址\n"

for i in "${!api_data_array[@]}"; do
    echo "$i | ${api_data_array[$i]}"
done

while true; do
    read -p "
请输入要选择的信息的编号（输入'q'退出）: " select_index

    if [ "$select_index" == "q" ]; then
        Digitalocean_memu
    fi

    if ! [[ "$select_index" =~ ^[0-9]+$ ]] || [ "$select_index" -lt 0 ] || [ "$select_index" -ge "${#api_data_array[@]}" ]; then
        continue
    fi

    selected_info=${api_data_array[$select_index]}
    api_name=${selected_info%%|*}
    DIGITALOCEAN_TOKEN=${selected_info#*|}
    break
done

	clear
	echo -e "`date` 正在进行 ${submodule} 删除VM操作\n"
	
json=$(curl -s -4 -X GET\
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  "https://api.digitalocean.com/v2/droplets")

o=$(echo "$json" | jq ".meta.total")

i=-1
while ((i < (o - 1)))
do
  ((i++))
  echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
  echo "$json" | jq -r ".droplets[${i}] | \"机器ID: \(.id), VM备注: \(.name), IPV4: \(.networks.v4[0].ip_address), \(.networks.v4[1].ip_address), 状态: \(.status)\""
done

read -e -p "请选择需要操作服务器的编号:" b
vm_id=$(echo "$json" | jq -r ".droplets[${b}].id")

if [[ $b -lt 0 || $b -ge $o ]]; then
  echo "错误：无效的编号"
  exit 1
fi

	echo -e "\nVM备注：${api_name}，VMID：${vm_id}\n"
	read -p "是否确认删除这台机器吗？(y/n): " confirm_delete
	if [ "$confirm_delete" == "y" ]; then
		echo -e "\n删除命令已发送，请稍等看看结果。"
json=`curl -s -4 -X DELETE \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
        "https://api.digitalocean.com/v2/droplets/${vm_id}"`
  read -s -n 1 -p "
按下回车键将返回 ${submodule} 菜单，输入'q'退出"
		
	if [[ $REPLY == "" ]]; then
		${submodule}_memu
	else
		exit 1
	fi
		else
		Digitalocean_memu
	fi
}

#do重置密码
do_passwd(){
	clear
	echo -e "`date` 正在进行 ${submodule} 重置VM密码\n"
	
	mapfile -t api_data_array < "$file_path/$submodule/api"

	if [ ${#api_data_array[@]} -eq 0 ]; then
		clear
		echo -e "`date` 正在进行 ${submodule} 查询API操\n\n当前API文件内无保存任何秘钥，请先添加API。"
		
		read -s -n 1 -p "按下回车键将返回 ${submodule} 菜单，输入'q'退出"
		
		if [[ $REPLY == "" ]]; then
			${submodule}_memu
		else
			exit 1
		fi
	fi

		echo -e "\n已保存的信息：\n编号 | API名字 | API地址\n"

for i in "${!api_data_array[@]}"; do
    echo "$i | ${api_data_array[$i]}"
done

while true; do
    read -p "
请输入要选择的信息的编号（输入'q'退出）: " select_index

    if [ "$select_index" == "q" ]; then
        Digitalocean_memu
    fi

    if ! [[ "$select_index" =~ ^[0-9]+$ ]] || [ "$select_index" -lt 0 ] || [ "$select_index" -ge "${#api_data_array[@]}" ]; then
        continue
    fi

    selected_info=${api_data_array[$select_index]}
    api_name=${selected_info%%|*}
    DIGITALOCEAN_TOKEN=${selected_info#*|}
    break
done

	clear
	echo -e "`date` 正在进行 ${submodule} 重置VM密码\n"
	
json=$(curl -s -4 -X GET\
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  "https://api.digitalocean.com/v2/droplets")

o=$(echo "$json" | jq ".meta.total")

i=-1
while ((i < (o - 1)))
do
  ((i++))
  echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
  echo "$json" | jq -r ".droplets[${i}] | \"机器ID: \(.id), VM备注: \(.name), IPV4: \(.networks.v4[0].ip_address), \(.networks.v4[1].ip_address), 状态: \(.status)\""
done

read -e -p "请选择需要操作服务器的编号:" b
vm_id=$(echo "$json" | jq -r ".droplets[${b}].id")

if [[ $b -lt 0 || $b -ge $o ]]; then
  echo "错误：无效的编号"
  exit 1
fi

	echo -e "\nVM备注：${api_name}，VMID：${vm_id}\n"
	read -p "是否确认重置这台机器吗？(y/n): " confirm_delete
	if [ "$confirm_delete" == "y" ]; then
		echo -e -n "\n重启命令正在发送，请稍后！"
json=`curl -s -X POST  \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  -d '{"type":"password_reset"}' \
  "https://api.digitalocean.com/v2/droplets/${vm_id}/actions"`
		echo "【完成】"
  read -s -n 1 -p "
按下回车键将返回 ${submodule} 菜单，输入'q'退出"
		
	if [[ $REPLY == "" ]]; then
		${submodule}_memu
	else
		exit 1
	fi
		else
			Digitalocean_memu
		fi
}

#do重启(硬)
do_power(){
	clear
	echo -e "`date` 正在进行 ${submodule} 重启VM(硬)\n"
	
	mapfile -t api_data_array < "$file_path/$submodule/api"

	if [ ${#api_data_array[@]} -eq 0 ]; then
		clear
		echo -e "`date` 正在进行 ${submodule} 查询API操\n\n当前API文件内无保存任何秘钥，请先添加API。"
		
		read -s -n 1 -p "按下回车键将返回 ${submodule} 菜单，输入'q'退出"
		
		if [[ $REPLY == "" ]]; then
			${submodule}_memu
		else
			exit 1
		fi
	fi

		echo -e "\n已保存的信息：\n编号 | API名字 | API地址\n"

for i in "${!api_data_array[@]}"; do
    echo "$i | ${api_data_array[$i]}"
done

while true; do
    read -p "
请输入要选择的信息的编号（输入'q'退出）: " select_index

    if [ "$select_index" == "q" ]; then
        Digitalocean_memu
    fi

    if ! [[ "$select_index" =~ ^[0-9]+$ ]] || [ "$select_index" -lt 0 ] || [ "$select_index" -ge "${#api_data_array[@]}" ]; then
        continue
    fi

    selected_info=${api_data_array[$select_index]}
    api_name=${selected_info%%|*}
    DIGITALOCEAN_TOKEN=${selected_info#*|}
    break
done

	clear
	echo -e "`date` 正在进行 ${submodule} 重启VM(硬)\n"
	
json=$(curl -s -4 -X GET\
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  "https://api.digitalocean.com/v2/droplets")

o=$(echo "$json" | jq ".meta.total")

i=-1
while ((i < (o - 1)))
do
  ((i++))
  echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
  echo "$json" | jq -r ".droplets[${i}] | \"机器ID: \(.id), VM备注: \(.name), IPV4: \(.networks.v4[0].ip_address), \(.networks.v4[1].ip_address), 状态: \(.status)\""
done

read -e -p "请选择需要操作服务器的编号:" b
vm_id=$(echo "$json" | jq -r ".droplets[${b}].id")

if [[ $b -lt 0 || $b -ge $o ]]; then
  echo "错误：无效的编号"
  exit 1
fi

	echo -e "\nVM备注：${api_name}，VMID：${vm_id}\n"
	read -p "是否确认重启(硬)？(y/n): " confirm_delete
	if [ "$confirm_delete" == "y" ]; then
		echo -e -n "\n重启命令正在发送，请稍后！"
json=`curl -s -X POST  \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  -d '{"type":"power_off"}' \
  "https://api.digitalocean.com/v2/droplets/${vm_id}/actions"`
  sleep 10
  json=`curl -s -X POST  \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  -d '{"type":"power_on"}' \
  "https://api.digitalocean.com/v2/droplets/${vm_id}/actions"`
		echo "【完成】"
  read -s -n 1 -p "
按下回车键将返回 ${submodule} 菜单，输入'q'退出"
		
	if [[ $REPLY == "" ]]; then
		${submodule}_memu
	else
		exit 1
	fi
		else
			Digitalocean_memu
		fi
}

#do重启(软)
do_reboot(){
	clear
	echo -e "`date` 正在进行 ${submodule} 重启VM(软)\n"
	
	mapfile -t api_data_array < "$file_path/$submodule/api"

	if [ ${#api_data_array[@]} -eq 0 ]; then
		clear
		echo -e "`date` 正在进行 ${submodule} 查询API操\n\n当前API文件内无保存任何秘钥，请先添加API。"
		
		read -s -n 1 -p "按下回车键将返回 ${submodule} 菜单，输入'q'退出"
		
		if [[ $REPLY == "" ]]; then
			${submodule}_memu
		else
			exit 1
		fi
	fi

		echo -e "\n已保存的信息：\n编号 | API名字 | API地址\n"

for i in "${!api_data_array[@]}"; do
    echo "$i | ${api_data_array[$i]}"
done

while true; do
    read -p "
请输入要选择的信息的编号（输入'q'退出）: " select_index

    if [ "$select_index" == "q" ]; then
        Digitalocean_memu
    fi

    if ! [[ "$select_index" =~ ^[0-9]+$ ]] || [ "$select_index" -lt 0 ] || [ "$select_index" -ge "${#api_data_array[@]}" ]; then
        continue
    fi

    selected_info=${api_data_array[$select_index]}
    api_name=${selected_info%%|*}
    DIGITALOCEAN_TOKEN=${selected_info#*|}
    break
done

	clear
	echo -e "`date` 正在进行 ${submodule} 重启VM(软)\n"
	
json=$(curl -s -4 -X GET\
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  "https://api.digitalocean.com/v2/droplets")

o=$(echo "$json" | jq ".meta.total")

i=-1
while ((i < (o - 1)))
do
  ((i++))
  echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
  echo "$json" | jq -r ".droplets[${i}] | \"机器ID: \(.id), VM备注: \(.name), IPV4: \(.networks.v4[0].ip_address), \(.networks.v4[1].ip_address), 状态: \(.status)\""
done

read -e -p "请选择需要操作服务器的编号:" b
vm_id=$(echo "$json" | jq -r ".droplets[${b}].id")

if [[ $b -lt 0 || $b -ge $o ]]; then
  echo "错误：无效的编号"
  exit 1
fi

	echo -e "\nVM备注：${api_name}，VMID：${vm_id}\n"
	read -p "是否确认重启(软)？(y/n): " confirm_delete
	if [ "$confirm_delete" == "y" ]; then
		echo -e "\n重启命令已发送，请稍等看看结果。"
json=`curl -s -X POST  \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  -d '{"type":"reboot"}' \
  "https://api.digitalocean.com/v2/droplets/${vm_id}/actions"`
  read -s -n 1 -p "
按下回车键将返回 ${submodule} 菜单，输入'q'退出"
		
	if [[ $REPLY == "" ]]; then
		${submodule}_memu
	else
		exit 1
	fi
	
		else
			Digitalocean_memu
		fi
	
}

#dovm信息
do_info_vm(){
	clear
	echo -e "`date` 正在进行 ${submodule} 查询VM信息\n"
	
	mapfile -t api_data_array < "$file_path/$submodule/api"

	if [ ${#api_data_array[@]} -eq 0 ]; then
		clear
		echo -e "`date` 正在进行 ${submodule} 查询API操\n\n当前API文件内无保存任何秘钥，请先添加API。"
		
		read -s -n 1 -p "按下回车键将返回 ${submodule} 菜单，输入'q'退出"
		
		if [[ $REPLY == "" ]]; then
			${submodule}_memu
		else
			exit 1
		fi
	fi

		echo -e "\n已保存的信息：\n编号 | API名字 | API地址\n"

for i in "${!api_data_array[@]}"; do
    echo "$i | ${api_data_array[$i]}"
done

while true; do
    read -p "
请输入要选择的信息的编号（输入'q'退出）: " select_index

    if [ "$select_index" == "q" ]; then
        Digitalocean_memu
    fi

    if ! [[ "$select_index" =~ ^[0-9]+$ ]] || [ "$select_index" -lt 0 ] || [ "$select_index" -ge "${#api_data_array[@]}" ]; then
        continue
    fi

    selected_info=${api_data_array[$select_index]}
    api_name=${selected_info%%|*}
    DIGITALOCEAN_TOKEN=${selected_info#*|}
    break
done
	
	clear
	echo -e "`date` 正在进行 ${submodule} 查询VM信息\n"
	json=`curl -s -4 -X GET \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  "https://api.digitalocean.com/v2/droplets"`
  
  o=$(echo "$json" | jq ".meta.total")
	
	i=-1
	while ((i < (o - 1)))
	do
	((i++))
	echo -n -e "  ${Green_font_prefix}${i}.${Font_color_suffix}  "
	echo "$json" | jq -r ".droplets[${i}] | \"机器ID: \(.id), VM备注: \(.name), IPV4: \(.networks.v4[0].ip_address), \(.networks.v4[1].ip_address), 状态: \(.status)\""
	done
	
	read -s -n 1 -p "
按下回车键将返回 ${submodule} 菜单，输入'q'退出"
		
	if [[ $REPLY == "" ]]; then
		${submodule}_memu
	else
		exit 1
	fi
}

#do创建vm
do_create_vm(){
	###选择API
	clear
	echo -e "`date` 正在进行 ${submodule} 创建VM操作"
	
	mapfile -t api_data_array < "$file_path/$submodule/api"

	if [ ${#api_data_array[@]} -eq 0 ]; then
		clear
		echo -e "`date` 正在进行 ${submodule} 查询API操\n\n当前API文件内无保存任何秘钥，请先添加API。"
		
		read -s -n 1 -p "按下回车键将返回 ${submodule} 菜单，输入'q'退出"
		
		if [[ $REPLY == "" ]]; then
			${submodule}_memu
		else
			exit 1
		fi
	fi

		echo -e "\n已保存的信息：\n编号 | API名字 | API地址\n"

for i in "${!api_data_array[@]}"; do
    echo "$i | ${api_data_array[$i]}"
done

while true; do
    read -p "
请输入要选择的信息的编号（输入'q'退出）: " select_index

    if [ "$select_index" == "q" ]; then
        Digitalocean_memu
    fi

    if ! [[ "$select_index" =~ ^[0-9]+$ ]] || [ "$select_index" -lt 0 ] || [ "$select_index" -ge "${#api_data_array[@]}" ]; then
        continue
    fi

    selected_info=${api_data_array[$select_index]}
    api_name=${selected_info%%|*}
    DIGITALOCEAN_TOKEN=${selected_info#*|}
    break
done
	
	###VM备注
	clear
	echo -e "`date` 正在进行 ${submodule} 创建VM操作"
	
	read -p "
请输入VM备注名称，可英文和数字。（输入'q'退出）: " vm_name
	if [ "$api_name" == "q" ]; then
        Digitalocean_memu
    fi 
	
	###选择地区
	clear
	echo -e "`date` 正在进行 ${submodule} 创建VM操作\n"
	
	names=()
	ids=()
	
	while IFS= read -r line; do
	names+=("$(echo "$line" | jq -r '.name')")
	ids+=("$(echo "$line" | jq -r '.id')")
	done < <(echo "$do_region" | jq -c '.opencloud[]')

	select_region() {
		for ((i=0; i<${#names[@]}; i++)); do
		echo "$(($i+1)). ${names[$i]}"
		done
	}

	select_region
	
	read -p "
请输入的地区的序号: " choice
	
	while ! [[ $choice =~ ^[0-9]+$ && $choice -ge 1 && $choice -le ${#names[@]} ]]; do
		clear
		echo -e "`date` 正在进行 ${submodule} 创建VM操作\n"
		select_region
		read -p "
请输入的地区的序号:" choice
	done
	
	index=$((choice-1))
	region="${ids[$index]}"
	
	###选择系统
	clear
	echo -e "`date` 正在进行 ${submodule} 创建VM操作\n"
	
	names=()
ids=()
	
	while IFS= read -r line; do
  names+=("$(echo "$line" | jq -r '.name')")
  ids+=("$(echo "$line" | jq -r '.id')")
done < <(echo "$do_image" | jq -c '.opencloud[]')

select_region() {
  for ((i=0; i<${#names[@]}; i++)); do
    echo "$(($i+1)). ${names[$i]}"
  done
}

select_region
	
	read -p "
请输入的系统的序号: " choice
	
	while ! [[ $choice =~ ^[0-9]+$ && $choice -ge 1 && $choice -le ${#names[@]} ]]; do
		clear
		echo -e "`date` 正在进行 ${submodule} 创建VM操作\n"
		select_region
		read -p "
请输入的系统的序号:" choice
	done
	
	index=$((choice-1))
	image="${ids[$index]}"
	
	###选择配置
	clear
	echo -e "`date` 正在进行 ${submodule} 创建VM操作\n"
	
	names=()
	ids=()
	
	while IFS= read -r line; do
	names+=("$(echo "$line" | jq -r '.name')")
	ids+=("$(echo "$line" | jq -r '.id')")
	done < <(echo "$do_size" | jq -c '.opencloud[]')

	select_region() {
		for ((i=0; i<${#names[@]}; i++)); do
		echo "$(($i+1)). ${names[$i]}"
		done
	}

	select_region
	
	read -p "
请输入的配置的序号: " choice
	
	while ! [[ $choice =~ ^[0-9]+$ && $choice -ge 1 && $choice -le ${#names[@]} ]]; do
		clear
		echo -e "`date` 正在进行 ${submodule} 创建VM操作\n"
		select_region
		read -p "
请输入的配置的序号:" choice
	done
	
	index=$((choice-1))
	size="${ids[$index]}"
	
	###信息汇总
	clear
	echo -e "`date` 正在进行 ${submodule} 创建VM操作

使用账号：${api_name}
API地址：${DIGITALOCEAN_TOKEN}
机器备注：${vm_name}
服务器位置：${region}
服务器规格：${size}
机器系统: ${image}"

		read -p "
是否确认创建机器？(y/n): " confirm_delete
	
	if [ "$confirm_delete" == "y" ]; then
		echo "1"
	else
		Digitalocean_memu
	fi
	
	###创建VM
	clear
	echo -e "`date` 正在进行 ${submodule} 创建VM操作\n"
	echo -n -"\n正在创建VM，请稍后！"
	json=`curl -s -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
    -d '{
       "name":"'${vm_name}'",
       "region":"'${region}'",
       "size":"'${size}'",
       "image":"'${image}'",
       "backups":"false",
       "ipv6":"true",
       "user_data":"'"$(cat ${file_path}/userdata)"'"
    }' \
    https://api.digitalocean.com/v2/droplets`
    
    vm_id=`echo $json | jq -r '.droplet.id'`

    if [[ $vm_id == null ]];
    then
        clear
        echo -e "$json
在创建的时候发生了一点小问题，请提交issues！\n"
		read -s -n 1 -p "按下回车键将返回 ${submodule} 菜单，输入'q'退出"
		
		if [[ $REPLY == "" ]]; then
			${submodule}_memu
		else
			exit 1
		fi
    else
		echo "【成功，${vm_id}】"
    fi
	
	echo -n "正在获取VMIP，请稍后！"
	max_retries=5
	retry_interval=5

	while [[ $retries -lt $max_retries ]]; do
    json=$(curl -s -4 -X GET \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
      "https://api.digitalocean.com/v2/droplets/355389162"
    )

    ipv4_address=$(echo "$json" | jq -r '.droplet.networks.v4[0].ip_address')
	ipv6_address=$(echo "$json" | jq -r '.droplet.networks.v6[0].ip_address')

    if [[ -n "$ipv4_address" ]]; then
		echo "【成功，$ipv4_address；$ipv6_address】"
      break
    fi

    retries=$((retries + 1))
    sleep "$retry_interval"
  done

	echo -e "\n使用账号：${api_name}
机器备注：${vm_name}
服务器位置：${region}
服务器规格：${size}
机器系统: ${image}

IP地址为：$ipv4_address；$ipv6_address
用户名：root
密码：Opencloud@Leige
密码为固定密码，请立即修改！"
	
	read -s -n 1 -p "
按下回车键将返回 ${submodule} 菜单，输入'q'退出"
	
	if [[ $REPLY == "" ]]; then
		${submodule}_memu
	else
		exit 1
	fi
}

#do检测API
do_detection_api(){
clear
	echo -e "`date` 正在进行 ${submodule} API测活操作\nAPI名称 | 电子邮箱 | 账号配额| 账号余额 || 账号状态 |\n"
api_data=$(cat "$file_path/$submodule/api")

while IFS='|' read -r api_name url; do
  if [[ -n "$api_name" && -n "$url" ]]; then
    token=$(echo "$url" | awk -F '|' '{print $NF}')
    json=$(curl -s -4 -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $token" "https://api.digitalocean.com/v2/account")
    json2=$(curl -s -4 -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $token" "https://api.digitalocean.com/v2/customers/my/balance")

    email=$(echo "$json" | jq -r '.account.email')
    droplet_limit=$(echo "$json" | jq -r '.account.droplet_limit')
    month_to_date_balance=$(echo "$json2" | jq -r '.month_to_date_balance')
    account_status=$(echo "$json" | jq -r '.account.status')

    echo "$api_name | $email | $droplet_limit | $month_to_date_balance | $account_status"
  fi
done <<< "$api_data"
read -s -n 1 -p "
按下回车键将返回 ${submodule} 菜单，输入'q'退出"
		
	if [[ $REPLY == "" ]]; then
		${submodule}_memu
	else
		exit 1
	fi
}

#查询API
query_api(){

	mapfile -t api_data_array < "$file_path/$submodule/api"

	if [ ${#api_data_array[@]} -eq 0 ]; then
		clear
		echo "`date` 正在进行 ${submodule} 查询API操作

当前API文件内无保存任何秘钥，请先添加API。
"
		read -s -n 1 -p "按下回车键将返回 ${submodule} 菜单，输入'q'退出"
		
		if [[ $REPLY == "" ]]; then
			${submodule}_memu
		else
			exit 1
		fi
	fi

		clear
		echo "`date` 正在进行 ${submodule} 查询API操作

已保存的信息：
编号 | API名字 | API地址
"

		for i in "${!api_data_array[@]}"; do
			echo "$i | ${api_data_array[$i]}"
		done
	
	read -s -n 1 -p "
按下回车键将返回 ${submodule} 菜单，输入'q'退出"
		
	if [[ $REPLY == "" ]]; then
		${submodule}_memu
	else
		exit 1
	fi
	
}

#删除API
del_api(){

	mapfile -t api_data_array < "$file_path/$submodule/api"

	if [ ${#api_data_array[@]} -eq 0 ]; then
		clear
		echo "`date` 正在进行 ${submodule} 删除API操作

当前API文件内无保存任何秘钥，请先添加API。
"
		read -s -n 1 -p "按下回车键将返回 ${submodule} 菜单，输入'q'退出"
		
		if [[ $REPLY == "" ]]; then
			${submodule}_memu
		else
			exit 1
		fi
	fi

	while true; do
	
		clear
		echo "`date` 正在进行 ${submodule} 删除API操作

已保存的信息：
编号 | API名字 | API地址
"

		for i in "${!api_data_array[@]}"; do
			echo "$i | ${api_data_array[$i]}"
		done
	
		read -p "
请输入要删除的信息的编号（输入'q'退出）: 
" delete_index
	
		if [ "$delete_index" == "q" ]; then
			${submodule}_memu
		fi
	
		if ! [[ "$delete_index" =~ ^[0-9]+$ ]] || [ "$delete_index" -lt 0 ] || [ "$delete_index" -ge "${#api_data_array[@]}" ]; then
			continue
		fi
	
		echo "要删除的信息：${api_data_array[$delete_index]}
		"
	
		read -p "是否确认删除？(y/n): " confirm_delete
	
		if [ "$confirm_delete" == "y" ]; then
		
			unset "api_data_array[$delete_index]"
			
			printf "%s\n" "${api_data_array[@]}" > "$file_path/$submodul"
	
			echo "
API删除完成。
"
		else
			continue
		fi
		
		
		read -p "是否继续删除？(y/n): " continue_delete
	
		if [ "$continue_delete" != "y" ]; then
			${submodule}_memu
			break
		fi
	done
}

#添加api
add_api(){

	mapfile -t api_data_array < "$file_path/$submodule/api"
	
	clear
	echo "`date` 正在进行 ${submodule} 添加API操作

已保存的信息：
编号 | API名字 | API地址
"
	
	
	for i in "${!api_data_array[@]}"; do
		echo "$i | ${api_data_array[$i]}"
	done
	
read -p "
请输入API名称: " api_name
read -p "请输入API地址: " api_address

echo "$api_name|$api_address" >> $file_path/$submodule/api

read -p "添加成功，是否需要继续添加API？(Y/N): " confirm

if [[ $confirm == "Y" || $confirm == "y" ]]; then
    add_api
else
	Digitalocean_memu
fi
}

#do菜单
Digitalocean_memu() {
  clear
   echo -e "Digitalocean 开机脚本${Red_font_prefix} 开源免费 无加密代码${Font_color_suffix} ${Green_font_prefix}from Telegram：@LeiGe_233 @openccloud${Font_color_suffix}
项目地址：${Red_font_prefix}https://github.com/LG-leige/open_cloud${Font_color_suffix}

API功能：————————————————————————————————————————————————————————
 ${Green_font_prefix}1.${Font_color_suffix} 全部API测活
 ${Green_font_prefix}2.${Font_color_suffix} 查询现有API
 ${Green_font_prefix}3.${Font_color_suffix} 添加api
 ${Green_font_prefix}4.${Font_color_suffix} 删除api

Droplet操作：————————————————————————————————————————————————————
 ${Green_font_prefix}5.${Font_color_suffix} 查询现有机器
 ${Green_font_prefix}6.${Font_color_suffix} 创建机器
 ${Green_font_prefix}7.${Font_color_suffix} 删除机器
 ${Green_font_prefix}8.${Font_color_suffix} 重启机器(软)
 ${Green_font_prefix}9.${Font_color_suffix} 重启机器(硬)
 ${Green_font_prefix}10.${Font_color_suffix} 重置ROOT密码（新密码会发送账号邮箱内）
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}0.${Font_color_suffix} 返回主菜单
————————————————————————————————————————————————————————————————" &&

read -p " 请输入数字 :" num
  case "$num" in
	1)
	submodule="Digitalocean"
	do_detection_api
	;;
    2)
	submodule="Digitalocean"
	query_api
	;;
    3)
	submodule="Digitalocean"
    add_api
	;;
	4)
	submodule="Digitalocean"
	del_api
	;;
	5)
	submodule="Digitalocean"
	do_info_vm
    ;;
	6)
	submodule="Digitalocean"
	do_create_vm
	;;
	7)
	submodule="Digitalocean"
	do_vm_del
	;;
	8)
	submodule="Digitalocean"
	do_reboot
	;;
	9)
	submodule="Digitalocean"
	do_power
	;;
  *)
    clear
    echo -e "${Error}:请输入正确数字 [0-99]（2秒后返回）"
    sleep 2s
    menu
    ;;
  esac
}

#初始化
initialization(){
    mkdir -p ${file_path}/digitalocean

	if [ ! -f "${file_path}/userdata" ]; then
		echo "#!/bin/bash
                
sudo service iptables stop 2> /dev/null ; chkconfig iptables off 2> /dev/null ;
sudo sed -i.bak '/^SELINUX=/cSELINUX=disabled' /etc/sysconfig/selinux;
sudo sed -i.bak '/^SELINUX=/cSELINUX=disabled' /etc/selinux/config;
sudo setenforce 0;
echo root:Opencloud@Leige |sudo chpasswd root;
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config;
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
sudo service sshd restart;" > "${file_path}/userdata"
	fi
}

#主菜单
menu() {
  clear
  echo -e "云服务开机脚本${Red_font_prefix} 开源免费 无加密代码${Font_color_suffix} ${Green_font_prefix}from Telegram：@LeiGe_233 @openccloud${Font_color_suffix}
项目地址：${Red_font_prefix}https://github.com/LG-leige/open_cloud${Font_color_suffix}
 ${Green_font_prefix}1.${Font_color_suffix} Digitalocean 开机脚本
————————————————————————————————————————————————————————————————" &&

read -p " 请输入数字 :" num
  case "$num" in
    1)
    Digitalocean_memu
    ;;
	*)
    clear
    echo -e "${Error}:请输入正确数字 [0-99]（2秒后返回）"
    sleep 2s
    menu
    ;;
  esac
}

initialization
if [[ $1 == "do" ]]; then
    Digitalocean_memu
#elif [[ $1 == "aws" ]]; then
#    menu
else
    menu
fi