$account = @("test-stor-1","test-stor-2")
$reg = @("grp-nfs-1","grps-nfs-2")

$pool_list = @()
for($i=0; $i -le $account.Count; $i++)
{
    $return = Get-AzNetAppFilesPool -ResourceGroupName $reg[$i] -AccountName $account[$i] | Out-String | ConvertFrom-Json
    $pool_list+= ($return.name).split("/")[1]
    foreach ($item in $pool_list)
    {
        $return_volume = Get-AzNetAppFilesVolume -ResourceGroupName $reg[$i] -AccountName $account[$i] -PoolName $item | Out-String | ConvertFrom-Json
        $vol_list+= ($return_volume.name).split("/")[2]
        foreach ($item2 in $vol_list)
        {
            $alert_name = "" + $item2 + " Metrics Alert"
            $return_alert = Get-AzureRmAlertRule -ResourceGroupName $reg[$i] -Name $alert_name | Out-String | ConvertFrom-Json
            $threshold = $return_alert.usagethreshold

            $current_vol_allocated = $return_volume.usageThreshold

            if ($threshold -ne ($current_vol_allocated*0.90))
            {
                #update alert
                Add-AzureRmMetricAlertRule -Name $alert_name -Threshold ($current_vol_allocated*0.90)
            }
            else
            {
             echo "no update required"
            }
        }
    }
}

