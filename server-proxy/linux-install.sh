#!/bin/bash
# Install privch service on Debian and Ubuntu
# updated: 2024-01
# https://xinlake.dev

PRIVCH_INSTALL_DIR="/usr/local/xinlake-privch"
PRIVCH_SERVICE_NAME="privch.service"
PRIVCH_SERVICE_CTRL="privch.sh"
PRIVCH_ID_FILENAME="privch.id"
PRIVCH_ED25519_FILENAME="privch.pem"

SS_PACKAGE_URL="https://github.com/xinlake/privch/raw/dev/server-proxy/.lfs/linux-ss.rust-v1.17.2c-gnu-x64.tar.xz"
SS_PACKAGE_SHA256="74b28913cdcff6fcf97902ea22890973cd6b68b6eb5fc8e79b02ac033d2d29f5"

PATTERN_IP4='^([0-9]{1,3}\.){3}[0-9]{1,3}$'
PATTERN_URL='^(http|https)://[^ "]+$'

# FUNCTIONS
echo_blue() {
    local message="$1"
    echo -e "\e[34m$message\e[0m"
}

echo_warning() {
    local message="$1"
    echo -e "\e[33m$message\e[0m"
}

gen_random_password() {
    echo $(tr -dc 'A-Za-z0-9!?%=' < /dev/urandom | head -c 12)
}

gen_ed25519_key() {
    local key_path=$1
    local overwrite=$2

    if [[ ! -f "$key_path" || $overwrite ]]; then
        openssl genpkey -algorithm ED25519 -outform PEM -out "$key_path"
    fi

    if [[ -f "$key_path" ]]; then
        return 0
    fi

    echo_warning "Unable to generate key"
    return 1
}

# check if the user has root access
check_root_access() {
    if [[ $EUID -ne 0 ]]; then
        echo_warning "This script is designed to be run exclusively by the root user."
        return 1
    fi

    # indicate success (true)
    return 0
}

# check if the system is supported
check_system_compatibility() {
    local system_id=$(lsb_release --short --id | tr "[:upper:]" "[:lower:]")
    local system_version=$(lsb_release --short --release | cut -d'.' -f1)
    local system_arch=$(arch)
    local system_bits=$(getconf LONG_BIT)

    if [[ "$system_id" == "debian" ]]; then
        if [[ "$system_version" -lt 12 ]]; then
            echo_warning "This script supports only Debian 12 or newer, and Ubuntu 22 or newer systems."
            return 1
        fi
    elif [[ "$system_id" == "ubuntu" ]]; then
        if [[ "$system_version" -lt 22 ]]; then
            echo_warning "This script supports only Debian 12 or newer, and Ubuntu 22 or newer systems."
            return 1
        fi
    else
        echo_warning "This script supports only Debian 12 or newer, and Ubuntu 22 or newer systems."
        return 1
    fi

    if [[ "$system_arch" != "x86_64" ]]; then
        echo_warning "This script only supports x86-64 machines."
        return 1
    fi

    # indicate success (true)
    return 0
}

# check if the service has already installed
check_service_installed() {
    if [[ -f "$PRIVCH_INSTALL_DIR/ssserver" ]]; then
        echo_warning "File ($PRIVCH_INSTALL_DIR/ssserver) already exists."
        return 1
    fi

    if systemctl status "$PRIVCH_SERVICE_NAME" >/dev/null 2>&1; then
        echo_warning "Service ($PRIVCH_SERVICE_NAME) already installed."
        return 1
    fi

    # indicate success (true)
    return 0
}

get_random_port() {
    local min_port=$1
    local max_port=$2
    local port

    while true; do
        port=$((RANDOM % (max_port - min_port + 1) + min_port))
        
        (echo >/dev/tcp/127.0.0.1/$port) &>/dev/null
        if [ $? -ne 0 ]; then
            echo "$port"
            break
        fi
    done
}

# install shadowsocks-rust
install_ss_rust() {
    echo "Download shadowsocks-rust ..."
    local download_file_name="shadowsocks-rust.tar.xz"

    curl --silent --location $SS_PACKAGE_URL --output "$PRIVCH_INSTALL_DIR/$download_file_name"
    if [[ ! -f "$PRIVCH_INSTALL_DIR/$download_file_name" ]]; then
        echo_warning "Unable to download $SS_PACKAGE_URL."
        return 1
    fi

    # check file hash
    local download_file_hash=$(sha256sum "$PRIVCH_INSTALL_DIR/$download_file_name" \
        | awk '{print $1}' | tr '[:upper:]' '[:lower:]')
    if [[ "$download_file_hash" != "$SS_PACKAGE_SHA256" ]]; then
        echo_warning "The hash value of $download_file_name is incorrect."
        return 1
    fi

    tar -xf "$PRIVCH_INSTALL_DIR/$download_file_name" --directory "$PRIVCH_INSTALL_DIR"

    chmod +x "$PRIVCH_INSTALL_DIR/sslocal"
    chmod +x "$PRIVCH_INSTALL_DIR/ssserver"

    rm "$PRIVCH_INSTALL_DIR/$download_file_name"    
    return 0
}

# START HERE
if [[ ! check_root_access || ! check_system_compatibility || ! check_service_installed ]]; then
    exit 1
fi

# parameters
privch_endpoint_storage=""
privch_update_key=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --storage-endpoint)
            shift
            if [[ $1 =~ $PATTERN_URL ]]; then
                privch_endpoint_storage="$1"
                shift
            else
                echo_warning "Invalid value of --storage-endpoint" >&2
                exit 1
            fi
            ;;
        --update-key)
            update_key=true
            shift
            ;;
        *)
            echo_warning "Invalid parameter: '$1'." >&2
            exit 1
            ;;
    esac
done

# upgrade packages, install necessary packages
apt update
apt install -y xxd tar qrencode curl ufw

# preparing
mkdir -m 0755 -p "$PRIVCH_INSTALL_DIR"

# genkey
if [[ "$privch_endpoint_storage" ]]; then
    if ! $(gen_ed25519_key "$PRIVCH_INSTALL_DIR/$PRIVCH_ED25519_FILENAME" $update_key); then
        exit 1
    fi
fi

if ! install_ss_rust; then
    exit 1
fi

# create service control script
cat > "$PRIVCH_INSTALL_DIR/$PRIVCH_SERVICE_CTRL" << EOF
#!/bin/bash

# TODO: generate random parameters
# "$(get_random_port 7000 12000) aes-256-gcm $(gen_random_password)"
# "$(get_random_port 17000 26000) aes-256-gcm $(gen_random_password)"
# "$(get_random_port 27000 33000) aes-256-gcm $(gen_random_password)"
# "$(get_random_port 57000 65000) aes-256-gcm $(gen_random_password)"
ss_list=(
    "7039 aes-256-gcm hello-ss"
    "7040 aes-256-gcm hello-ss"
)

echo_purple() {
    local message="\$1"
    echo -e "\e[35m\$message\e[0m"
}

build_put_content() {
    local list=("\$@")
    local content=''

    local first=true
    for item in "\${list[@]}"; do
        if ! \$first; then
            content+="\\n"
        fi
            
        first=false
        content+="\$item"        
    done

    echo "\$content"
}

start_service() {
    local ss_params

    # setup firewall, enable ssh and shadowsocks port
    for ss in "\${ss_list[@]}"; do
        read -ra ss_params <<< "\$ss"
        ufw allow "\${ss_params[0]}"/tcp
        ufw allow "\${ss_params[0]}"/udp
    done

    ufw allow 22/tcp
    ufw --force enable

    # start shadowsocks server
    for ss in "\${ss_list[@]}"; do
        read -ra ss_params <<< "\$ss"
        "$PRIVCH_INSTALL_DIR/ssserver" --server-addr "[::]:\${ss_params[0]}" \\
            --encrypt-method "\${ss_params[1]}" --password "\${ss_params[2]}" -U &
    done

    # register with the backend
    if [[ "$privch_endpoint_storage" && -f "$PRIVCH_INSTALL_DIR/$PRIVCH_ED25519_FILENAME" ]]; then
        local put_status
        local public_ip=\$(curl --silent "https://api.ipify.org")
        
        if [[ \$public_ip =~ $PATTERN_IP4 ]]; then
            echo -n "\$public_ip" | b2sum --length 512 | tr -d "[:blank:]-\n" \\
                | sudo --preserve-env tee "$PRIVCH_INSTALL_DIR/$PRIVCH_ID_FILENAME" > /dev/null

            local signature=\$(sudo --preserve-env openssl pkeyutl -sign \\
                -rawin -in "$PRIVCH_INSTALL_DIR/$PRIVCH_ID_FILENAME" \\
                -inkey "$PRIVCH_INSTALL_DIR/$PRIVCH_ED25519_FILENAME" -keyform PEM | base64 --wrap 0)
            
            # put
            local retry_count=0
            local post_data='{
                "signature": "'"\$signature"'",
                "action": "put",
                "blob-name": "'"\$public_ip"'",
                "content": "'"\$(build_put_content "\${ss_list[@]}")"'"
            }'

            while [ "\$retry_count" -lt 7 ]; do
                put_status=\$(curl --silent --connect-timeout 70 \\
                    --output /dev/null --write-out "%{http_code}" \\
                    --header "content-type: application/json" \\
                    --data "\$post_data" "$privch_endpoint_storage")

                if [ "\$put_status" -eq 200 ]; then
                    break
                else
                    ((retry_count++))
                fi

                sleep 7
            done
        fi

        # action failed
        if [[ ! "\$put_status" -eq 200 ]]; then
            sudo rm -f "$PRIVCH_INSTALL_DIR/$PRIVCH_ID_FILENAME"
        fi
    fi
}

stop_service() {
    pkill --full "ssserver"
}

uninstall_service() {
    systemctl stop "$PRIVCH_SERVICE_NAME"
    systemctl disable "$PRIVCH_SERVICE_NAME"
    rm "/etc/systemd/system/$PRIVCH_SERVICE_NAME"

    rm "$PRIVCH_INSTALL_DIR/sslocal"
    rm "$PRIVCH_INSTALL_DIR/ssserver"
    rm -f "$PRIVCH_INSTALL_DIR/$PRIVCH_ID_FILENAME"
    rm "$PRIVCH_INSTALL_DIR/$PRIVCH_SERVICE_CTRL"

    if [[ -f "$PRIVCH_INSTALL_DIR/$PRIVCH_ED25519_FILENAME" ]]; then
        rm -i "$PRIVCH_INSTALL_DIR/$PRIVCH_ED25519_FILENAME"
    fi

    if [[ -d "$PRIVCH_INSTALL_DIR" ]]; then
        if [[ -z "\$(ls -A "$PRIVCH_INSTALL_DIR")" ]]; then
            rm --dir "$PRIVCH_INSTALL_DIR"
        fi
    fi
}

display_pubkey() {
    if [[ -f "$PRIVCH_INSTALL_DIR/$PRIVCH_ED25519_FILENAME" ]]; then
        local key_text=\$(openssl pkey -in "$PRIVCH_INSTALL_DIR/$PRIVCH_ED25519_FILENAME" -text)
        local key_pub=\$(grep -A 7 "pub:" <<< "\$key_text" | grep -v "pub:" \
            | tr -d '[:space:]:' | xxd -r -p | base64 --wrap 0)

        echo_purple "\$key_pub"
    else
        echo "Unable to read $PRIVCH_INSTALL_DIR/$PRIVCH_ED25519_FILENAME"
    fi
}

display_qrcode() {
    local pub_ip="\$(curl --silent "https://api.ipify.org")"
    
    local ss_params
    local ss_url
    for ss in "\${ss_list[@]}"; do
        read -ra ss_params <<< "\$ss"
        ss_url="ss://\$(echo "\${ss_params[1]}:\${ss_params[2]}@\$pub_ip:\${ss_params[0]}" \\
            | base64 --wrap 0 | sed "s/=*\$//")"

        echo -e "\n"
        qrencode -t ANSI "\$ss_url"
        echo -e "\n"
    done
}

case \$1 in
    "start")
        start_service
        ;;
    "stop")
        stop_service
        ;;
    "restart")
        stop_service
        sleep 1
        start_service
        ;;
    "uninstall")
        uninstall_service
        ;;
    "pubkey")
        display_pubkey
        ;;
    "qrcode")
        display_qrcode
        ;;
    ""|*)
        echo "Options: start | stop | restart | uninstall | pubkey | qrcode"
        echo -e "\n"
        ;;
esac
EOF

# create service
cat > "/etc/systemd/system/$PRIVCH_SERVICE_NAME" << EOF
[Unit]
Description="Private Channel"
After=network.target

[Service]
Type=forking
ExecStart="$PRIVCH_INSTALL_DIR/$PRIVCH_SERVICE_CTRL" start
ExecStop="$PRIVCH_INSTALL_DIR/$PRIVCH_SERVICE_CTRL" stop
ExecRestart="$PRIVCH_INSTALL_DIR/$PRIVCH_SERVICE_CTRL" restart

[Install]
WantedBy=multi-user.target
EOF

# enable and start service
chmod +x "$PRIVCH_INSTALL_DIR/$PRIVCH_SERVICE_CTRL"
systemctl enable "$PRIVCH_SERVICE_NAME"
systemctl start "$PRIVCH_SERVICE_NAME"

# FINISH
echo_blue "\nPrivate Channel Service is Ready.\n"

if [[ "$privch_endpoint_storage" ]]; then
    "$PRIVCH_INSTALL_DIR/$PRIVCH_SERVICE_CTRL" pubkey
else
    "$PRIVCH_INSTALL_DIR/$PRIVCH_SERVICE_CTRL" qrcode
fi
