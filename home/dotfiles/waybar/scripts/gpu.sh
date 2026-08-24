#!/usr/bin/env bash
# GPU readout for waybar (NVIDIA 3070 Ti, proprietary driver).
# Emits JSON: text = temp + util, tooltip = the full picture.
# One nvidia-smi call, not five - each invocation costs ~30ms.

read -r temp util mem_used mem_total power fan < <(
    nvidia-smi --format=csv,noheader,nounits \
        --query-gpu=temperature.gpu,utilization.gpu,memory.used,memory.total,power.draw,fan.speed \
        2>/dev/null | tr -d ',' 
)

if [[ -z $temp ]]; then
    printf '{"text":"󰢮 --","tooltip":"nvidia-smi unavailable","class":"unavailable"}\n'
    exit 0
fi

# Class drives the colour in style.css.
class=normal
(( temp >= 80 )) && class=critical
(( temp >= 70 && temp < 80 )) && class=warning

# %2s / %3s: fixed width, so the bar doesn't shuffle when util hits 100%.
printf '{"text":"󰢮 %2s°C  %3s%%","tooltip":"GPU %s°C   %s%% util\\nVRAM %s / %s MiB\\nPower %s W   Fan %s%%","class":"%s"}\n' \
    "$temp" "$util" "$temp" "$util" "$mem_used" "$mem_total" "$power" "$fan" "$class"
