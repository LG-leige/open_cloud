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

Digitalocean_region='{"opencloud":[{"name":"New York 1（美国纽约 1）","id":"nyc1"},{"name":"San Francisco 1（美国旧金山 1）","id":"sfo1"},{"name":"Singapore 1（新加坡 1）","id":"sgp1"},{"name":"London 1（英国伦敦 1）","id":"lon1"},{"name":"New York 3（美国纽约 3）","id":"fra1"},{"name":"Amsterdam 3（荷兰 3）","id":"ams3"},{"name":"Frankfurt 1（德国 1）","id":"fra1"},{"name":"Toronto 1（加拿大 1）","id":"tor1"},{"name":"Bangalore 1（印度 1）","id":"blr1"},{"name":"San Francisco 3（美国旧金山 3）","id":"sfo3"},{"name":"Sydney Australia 1（澳大利亚1 ）","id":"syd1"}]}'
Digitalocean_size='{"opencloud":[{"name":"1Vcpu(Regular) 512GB 0.5TB $4.00【仅 荷兰 美国纽约 美国旧金山3 澳大利亚 可用】","id":"s-1vcpu-512mb-10gb"},{"name":"1Vcpu(Regular) 1GB 1TB $6.00","id":"s-1vcpu-1gb"},{"name":"1Vcpu(Regular) 2GB 2TB $12.00","id":"s-1vcpu-2gb"},{"name":"2Vcpu(Regular) 2GB 3TB $18.00","id":"s-2vcpu-2gb"},{"name":"2Vcpu(Regular) 4GB 4TB $24.00","id":"s-2vcpu-4gb"},{"name":"1Vcpu(amd) 1GB 1TB $7.00","id":"s-1vcpu-1gb-amd"},{"name":"1Vcpu(amd) 2GB 2TB $14.00","id":"s-1vcpu-2gb-amd"},{"name":"2Vcpu(amd) 2GB 3TB $21.00","id":"s-2vcpu-2gb-amd"},{"name":"2Vcpu(amd) 2GB 4TB $28.00","id":"s-2vcpu-4gb-amd"},{"name":"1Vcpu(intel) 1GB 1TB $7.00","id":"s-1vcpu-1gb-intel"},{"name":"1Vcpu(intel) 2GB 2TB $14.00","id":"s-1vcpu-2gb-intel"},{"name":"2Vcpu 2GB 3TB $21.00","id":"s-2vcpu(intel)-2gb-intel"},{"name":"2Vcpu(intel) 4GB 4TB $28.00","id":"s-2vcpu-4gb-intel"}]}'
Digitalocean_image='{"opencloud":[{"name":"centos-7-x64","id":"centos-7-x64"},{"name":"centos-stream-8-x64","id":"centos-stream-8-x64"},{"name":"centos-stream-9-x64","id":"centos-stream-9-x64"},{"name":"debian-10-x64","id":"debian-10-x64"},{"name":"debian-11-x64","id":"debian-11-x64"},{"name":"ubuntu-18-04-x64","id":"ubuntu-18-04-x64"},{"name":"ubuntu-20-04-x64","id":"ubuntu-20-04-x64"},{"name":"ubuntu-22-04-x64","id":"ubuntu-22-04-x64"}]}'

Linode_region='{"opencloud":[{"name":"ap-west（印度）","id":"ap-west"},{"name":"ca-central（加拿大）","id":"ca-central"},{"name":"ap-southeast（澳大利亚）","id":"ap-southeast"},{"name":"us-central（美国）","id":"us-central"},{"name":"us-west（美国）","id":"us-west"},{"name":"us-southeast（美国）","id":"us-southeast"},{"name":"us-east（美国）","id":"us-east"},{"name":"eu-west（英国）","id":"eu-west"},{"name":"ap-south（新加坡）","id":"ap-south"},{"name":"eu-central（德国）","id":"eu-central"},{"name":"ap-northeast（日本）","id":"ap-northeast"}]}'
Linode_size='{"opencloud":[{"name":"1Vcpu 1GB 1TB $5.00","id":"g6-nanode-1"},{"name":"1Vcpu 2GB 2TB $12.00","id":"g6-standard-1"},{"name":"2Vcpu 4GB 4TB $24.00","id":"g6-standard-2"},{"name":"4Vcpu 8GB 5TB $48.00","id":"g6-standard-4"},{"name":"6Vcpu 16GB 8TB $96.00","id":"g6-standard-6"}]}'
Linode_image='{"opencloud":[{"name":"Centos-stream8","id":"linode/centos-stream8"},{"name":"Centos-stream9","id":"linode/centos-stream9"},{"name":"Debian9","id":"linode/debian9"},{"name":"Debian10","id":"linode/debian10"},{"name":"Debian11","id":"linode/debian11"},{"name":"Ubuntu16.04_lts","id":"linode/ubuntu16.04lts"},{"name":"Ubuntu18.04","id":"linode/ubuntu18.04"},{"name":"Ubuntu20.04","id":"linode/ubuntu20.04"},{"name":"Ubuntu21.04","id":"Ubuntu21.04"},{"name":"Ubuntu21.10","id":"linode/ubuntu21.10"},{"name":"Ubuntu22.04","id":"linode/ubuntu22.04"}]}'

#linode删除vm【】
Linode_vm_del(){
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
        Linode_memu
    fi

    if ! [[ "$select_index" =~ ^[0-9]+$ ]] || [ "$select_index" -lt 0 ] || [ "$select_index" -ge "${#api_data_array[@]}" ]; then
        continue
    fi

    selected_info=${api_data_array[$select_index]}
    api_name=${selected_info%%|*}
    TOKEN=${selected_info#*|}
    break
done

	clear
	echo -e "`date` 正在进行 ${submodule} 删除VM操作\n"
	
json=$(curl -s -4 -X GET\
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
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
        -H "Authorization: Bearer $TOKEN" \
        "https://api.digitalocean.com/v2/droplets/${vm_id}"`
  read -s -n 1 -p "
按下回车键将返回 ${submodule} 菜单，输入'q'退出"
		
	if [[ $REPLY == "" ]]; then
		${submodule}_memu
	else
		exit 1
	fi
		else
		Linode_memu
	fi
}

#linode重置密码【】
Linode_passwd(){
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
        Linode_memu
    fi

    if ! [[ "$select_index" =~ ^[0-9]+$ ]] || [ "$select_index" -lt 0 ] || [ "$select_index" -ge "${#api_data_array[@]}" ]; then
        continue
    fi

    selected_info=${api_data_array[$select_index]}
    api_name=${selected_info%%|*}
    TOKEN=${selected_info#*|}
    break
done

	clear
	echo -e "`date` 正在进行 ${submodule} 重置VM密码\n"
	
json=$(curl -s -4 -X GET\
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
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
  -H "Authorization: Bearer $TOKEN" \
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
			Linode_memu
		fi
}

#linode重启(硬)【】
Linode_power(){
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
        Linode_memu
    fi

    if ! [[ "$select_index" =~ ^[0-9]+$ ]] || [ "$select_index" -lt 0 ] || [ "$select_index" -ge "${#api_data_array[@]}" ]; then
        continue
    fi

    selected_info=${api_data_array[$select_index]}
    api_name=${selected_info%%|*}
    TOKEN=${selected_info#*|}
    break
done

	clear
	echo -e "`date` 正在进行 ${submodule} 重启VM(硬)\n"
	
json=$(curl -s -4 -X GET\
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
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
  -H "Authorization: Bearer $TOKEN" \
  -d '{"type":"power_off"}' \
  "https://api.digitalocean.com/v2/droplets/${vm_id}/actions"`
  sleep 10
  json=`curl -s -X POST  \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
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
			Linode_memu
		fi
}

#linode重启(软)【】
Linode_reboot(){
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
        Linode_memu
    fi

    if ! [[ "$select_index" =~ ^[0-9]+$ ]] || [ "$select_index" -lt 0 ] || [ "$select_index" -ge "${#api_data_array[@]}" ]; then
        continue
    fi

    selected_info=${api_data_array[$select_index]}
    api_name=${selected_info%%|*}
    TOKEN=${selected_info#*|}
    break
done

	clear
	echo -e "`date` 正在进行 ${submodule} 重启VM(软)\n"
	
json=$(curl -s -4 -X GET\
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
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
  -H "Authorization: Bearer $TOKEN" \
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
			Linode_memu
		fi
	
}

#linodevm信息【】
Linode_info_vm(){
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
        Linode_memu
    fi

    if ! [[ "$select_index" =~ ^[0-9]+$ ]] || [ "$select_index" -lt 0 ] || [ "$select_index" -ge "${#api_data_array[@]}" ]; then
        continue
    fi

    selected_info=${api_data_array[$select_index]}
    api_name=${selected_info%%|*}
    TOKEN=${selected_info#*|}
    break
done
	
	clear
	echo -e "`date` 正在进行 ${submodule} 查询VM信息\n"
	json=`curl -s -4 -X GET \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
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

#linode创建vm
Linode_create_vm(){
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
        Linode_memu
    fi

    if ! [[ "$select_index" =~ ^[0-9]+$ ]] || [ "$select_index" -lt 0 ] || [ "$select_index" -ge "${#api_data_array[@]}" ]; then
        continue
    fi

    selected_info=${api_data_array[$select_index]}
    api_name=${selected_info%%|*}
    TOKEN=${selected_info#*|}
    break
done
	
	###VM备注
	clear
	echo -e "`date` 正在进行 ${submodule} 创建VM操作"
	
	read -p "
请输入VM备注名称，可英文和数字。（输入'q'退出）: " vm_name
	if [ "$api_name" == "q" ]; then
        Linode_memu
    fi 
	
	###选择地区
	clear
	echo -e "`date` 正在进行 ${submodule} 创建VM操作\n"
	
	names=()
	ids=()
	
	while IFS= read -r line; do
	names+=("$(echo "$line" | jq -r '.name')")
	ids+=("$(echo "$line" | jq -r '.id')")
	done < <(echo "$Linode_region" | jq -c '.opencloud[]')

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
done < <(echo "$Linode_image" | jq -c '.opencloud[]')

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
	done < <(echo "$Linode_size" | jq -c '.opencloud[]')

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
	passwd=$(grep -oP '(?<=echo root:)[^|]*' "${file_path}/userdata")
	
	###信息汇总
	clear
	echo -e "`date` 正在进行 ${submodule} 创建VM操作

使用账号：${api_name}
API地址：${TOKEN}
机器备注：${vm_name}
服务器位置：${region}
服务器规格：${size}
机器系统: ${image}
ROOT密码：${passwd}"


		read -p "
是否确认创建机器？(y/n): " confirm_delete
	
	if [ "$confirm_delete" == "y" ]; then
		echo "1"
	else
		Linode_memu
	fi
	
	###创建VM
	clear
	echo -e "`date` 正在进行 ${submodule} 创建VM操作\n"
	echo -n "正在创建VM，请稍后！"
    
    json=$(curl -s -H -4 "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -X POST -d '{
      "swap_size": 512,
      "image": "'${image}'",
      "root_pass": "'${passwd}'",
      "booted": true,
      "type": "'${size}'",
      "region": "'${region}'"
    }' \
    https://api.linode.com/v4/linode/instances)
    
    vm_id=`echo $json | jq -r '.id'`
    ipv4_address=`echo ${json} | jq -r '.ipv4'`
    ipv6_address=`echo ${json} | jq -r '.ipv6'`

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

	echo -e "\n使用账号：${api_name}
机器备注：${vm_name}
服务器位置：${region}
服务器规格：${size}
机器系统: ${image}

IP地址为：$ipv4_address；$ipv6_address
用户名：root
密码：${passwd}
如果是默认固定密码，请立即修改密码！"
	
	read -s -n 1 -p "
按下回车键将返回 ${submodule} 菜单，输入'q'退出"
	
	if [[ $REPLY == "" ]]; then
		${submodule}_memu
	else
		exit 1
	fi
}

#linode检测API
Linode_detection_api(){
clear
	echo -e "`date` 正在进行 ${submodule} API测活操作\nAPI名称 | 电子邮箱 | 账号余额（有余额就是活的）\n"
api_data=$(cat "$file_path/$submodule/api")

while IFS='|' read -r api_name url; do
  if [[ -n "$api_name" && -n "$url" ]]; then
    token=$(echo "$url" | awk -F '|' '{print $NF}')
    json=$(curl -s -4 -H "Authorization: Bearer $TOKEN" \
        "https://api.linode.com/v4/account")
    json2=$(curl -s -4 -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $token" "https://api.digitalocean.com/v2/customers/my/balance")

    email=$(echo "$json" | jq -r '.email')
    credit_remaining=$(echo "$json" | jq -r '.active_promotions[0].credit_remaining')
    echo "$api_name | $email | $credit_remaining"
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

#linode菜单
Linode_memu() {
  clear
   echo -e "Linode 开机脚本${Red_font_prefix} 开源免费 无加密代码${Font_color_suffix} ${Green_font_prefix}from Telegram：@openccloud${Font_color_suffix}
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
 ${Green_font_prefix}00.${Font_color_suffix} 修改开机密码
 ${Green_font_prefix}99.${Font_color_suffix} 返回主菜单
————————————————————————————————————————————————————————————————" &&

read -p " 请输入数字 :" num
  case "$num" in
	1)
	submodule="Linode"
	${submodule}_detection_api
	;;
    2)
	submodule="Linode"
	query_api
	;;
    3)
	submodule="Linode"
    add_api
	;;
	4)
	submodule="Linode"
	del_api
	;;
	5)
	submodule="Linode"
	${submodule}_info_vm
    ;;
	6)
	submodule="Linode"
	${submodule}_create_vm
	;;
	7)
	submodule="Linode"
	${submodule}_vm_del
	;;
	8)
	submodule="Linode"
	${submodule}_reboot
	;;
	9)
	submodule="Linode"
	${submodule}_power
	;;
	00)
	set_passwd
	;;
	99)
	menu
	;;
  *)
    clear
    echo -e "${Error}:请输入正确数字 [0-99]（2秒后返回）"
    sleep 2s
    menu
    ;;
  esac
}

#do删除vm
Digitalocean_vm_del(){
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
Digitalocean_passwd(){
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
Digitalocean_power(){
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
Digitalocean_reboot(){
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
Digitalocean_info_vm(){
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
	json=$(curl -s -4 -X GET \
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
	
	read -s -n 1 -p "
按下回车键将返回 ${submodule} 菜单，输入'q'退出"
		
	if [[ $REPLY == "" ]]; then
		${submodule}_memu
	else
		exit 1
	fi
}

#do创建vm
Digitalocean_create_vm(){
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
	done < <(echo "$Digitalocean_region" | jq -c '.opencloud[]')

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
done < <(echo "$Digitalocean_image" | jq -c '.opencloud[]')

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
	done < <(echo "$Digitalocean_size" | jq -c '.opencloud[]')

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
	passwd=$(grep -oP '(?<=echo root:)[^|]*' "${file_path}/userdata")
	
	###信息汇总
	clear
	echo -e "`date` 正在进行 ${submodule} 创建VM操作

使用账号：${api_name}
API地址：${DIGITALOCEAN_TOKEN}
机器备注：${vm_name}
服务器位置：${region}
服务器规格：${size}
机器系统: ${image}
ROOT密码：${passwd}"

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
	echo -n "正在创建VM，请稍后！"
	json=$(curl -s -X POST \
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
    https://api.digitalocean.com/v2/droplets)
    
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
	sleep 45
  json=$(curl -s -4 -X GET \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
    "https://api.digitalocean.com/v2/droplets/${vm_id}"
  )
    
  ipv4_address=$(echo "$json" | jq -r '.droplet.networks.v4[0].ip_address')
  ipv6_address=$(echo "$json" | jq -r '.droplet.networks.v6[0].ip_address')

  if [[ -n "$ipv4_address" && -n "$ipv6_address" ]]; then
    echo "【成功，$ipv4_address；$ipv6_address】"
  fi
  
if [[ -z "$ipv4_address" || -z "$ipv6_address" ]]; then
  echo -e "$json
在创建的时候发生了一点小问题，请提交issues！\n"
		read -s -n 1 -p "按下回车键将返回 ${submodule} 菜单，输入'q'退出"
		
		if [[ $REPLY == "" ]]; then
			${submodule}_memu
		else
			exit 1
		fi
fi


	echo -e "\n使用账号：${api_name}
机器备注：${vm_name}
服务器位置：${region}
服务器规格：${size}
机器系统: ${image}

IP地址为：$ipv4_address；$ipv6_address
用户名：root
密码：${passwd}
如果是默认固定密码，请立即修改密码！"
	
	read -s -n 1 -p "
按下回车键将返回 ${submodule} 菜单，输入'q'退出"
	
	if [[ $REPLY == "" ]]; then
		${submodule}_memu
	else
		exit 1
	fi
}

#do检测API
Digitalocean_detection_api(){
clear
	echo -e "`date` 正在进行 ${submodule} API测活操作\nAPI名称 | 电子邮箱 | 账号配额| 账号余额 | 账号状态 |\n"
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
		
		printf "%s\n" "${api_data_array[@]}" > "$file_path/$submodule/api"

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
   echo -e "Digitalocean 开机脚本${Red_font_prefix} 开源免费 无加密代码${Font_color_suffix} ${Green_font_prefix}from Telegram：@openccloud${Font_color_suffix}
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
 ${Green_font_prefix}00.${Font_color_suffix} 修改开机密码
 ${Green_font_prefix}99.${Font_color_suffix} 返回主菜单
————————————————————————————————————————————————————————————————" &&

read -p " 请输入数字 :" num
  case "$num" in
	1)
	submodule="Digitalocean"
	${submodule}_detection_api
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
	${submodule}_info_vm
    ;;
	6)
	submodule="Digitalocean"
	${submodule}_create_vm
	;;
	7)
	submodule="Digitalocean"
	${submodule}_vm_del
	;;
	8)
	submodule="Digitalocean"
	${submodule}_reboot
	;;
	9)
	submodule="Digitalocean"
	${submodule}_power
	;;
	00)
	set_passwd
	;;
	99)
	menu
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
	mkdir -p ${file_path}
    mkdir -p ${file_path}/Digitalocean
	mkdir -p ${file_path}/Linode

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

#修改开机默认密码
set_passwd(){
while true; do
clear
	echo "`date` 正在进行 修改开机默认密码 操作"
  read -s -p "请输入新密码: " password
  echo

  if [[ ${#password} -lt 8 || ${#password} -gt 16 || ! "$password" =~ [A-Z] || ! "$password" =~ [a-z] || ! "$password" =~ [0-9] || ! "$password" =~ [#@$!%.,/] ]]; then
    echo "密码必须是8到16个字符，包括大小写字母、数字和特殊符号 # @ $ ! % . , /"
  else
    break
  fi
done

while true; do
  read -s -p "请再次输入新密码: " password_confirmation
  echo

  if [[ "$password" != "$password_confirmation" ]]; then
    echo "两次输入的密码不一致，请重新输入！"
  else
    break
  fi
done

	rm -rf ${file_path}/userdata
	echo "#!/bin/bash
                
sudo service iptables stop 2> /dev/null ; chkconfig iptables off 2> /dev/null ;
sudo sed -i.bak '/^SELINUX=/cSELINUX=disabled' /etc/sysconfig/selinux;
sudo sed -i.bak '/^SELINUX=/cSELINUX=disabled' /etc/selinux/config;
sudo setenforce 0;
echo root:${password} |sudo chpasswd root;
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config;
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
sudo service sshd restart;" > "${file_path}/userdata"
read -s -n 1 -p "
开机默认密码已经修改为 ${password} 该密码是全局通用的。
按下回车键将返回 ${submodule} 菜单，输入'q'退出"
		
	if [[ $REPLY == "" ]]; then
		${submodule}_memu
	else
		exit 1
	fi
}

#主菜单
menu() {
  clear
  echo -e "云服务开机脚本${Red_font_prefix} 开源免费 无加密代码${Font_color_suffix} ${Green_font_prefix}from Telegram：@openccloud${Font_color_suffix}
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
<<<<<<< HEAD
=======
elif [[ $1 == "linode" ]]; then
    menu
>>>>>>> a1401e54afd73066b1bff6aba7cdc388bb06f9fb
else
    menu
fi
