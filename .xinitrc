
xrandr --setprovideroutputsource modesetting NVIDIA-0

.screenlayout/eDP-1_DP-1-8.sh

# script to detect new keyboard and set us,is keyboard toggle
{ echo "XIDeviceEnabled XISlaveKeyboard"; inputplug -d -c /bin/echo; } |
while read event
do
        case $event in
        XIDeviceEnabled*XISlaveKeyboard*)
                setxkbmap us,is -option grp:alt_shift_toggle
                ;;
        esac
done &

nm-applet &
sxhkd &
blueman-applet &

# start awesome
awesome
