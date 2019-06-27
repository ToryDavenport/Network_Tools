# Populate interface names for future use (iteration)
$interfaces = Get-NetAdapter | ForEach-Object {$_.InterfaceAlias + "`n"}

# Implement features
function show-ipdetail {
    Clear-Host
    Write-Host -Verbose "Loading, please wait!"
    # Get network config details, expand IPv4Address property and output the address and interface name into a table
    Get-NetIPConfiguration | Select-Object -ExpandProperty IPv4Address | Select-Object IPAddress, InterfaceAlias | Format-Table
}

function show-interfaces {
    Clear-Host
    # Get network adapter information and filter by properties, output into a table
    Get-NetAdapter | select-object -Property Name, ifIndex, Status, MacAddress, LinkSpeed |format-table
} 
 
function show-defaultgateway {
    Clear-Host
    Write-Host -Verbose "Loading, please wait!"
    # Get Network Adapters that are currently connected, output default gateway information
    Get-NetAdapter | Where-Object {$_.Status -eq 'UP'} | Get-NetIPConfiguration | Select-Object -ExpandProperty IPv4DefaultGateway | Format-Table @{L= 'Default Gateway';E={$_.NextHop}}
}

function set-dnsserver {
    Clear-Host
    Write-Host "Availible Interfaces:`n"$interfaces""
    [string]$interfaceAlias = Read-Host "Choose an adapter from the list"
    [string]$primaryDNS = Read-Host "Enter a primary DNS server: "
    [string]$secondaryDNS = Read-Host "Enter a primary DNS server: "
    try {
    # Set DNS servers and hide output
    Set-DnsClientServerAddress -InterfaceAlias $interfaceAlias -ServerAddresses ("$primaryDNS","$secondaryDNS") -Confirm:$false -ErrorAction SilentlyContinue > null
    }
  catch {
    Write-Host -ForegroundColor DarkYellow -BackgroundColor Black "An error has occured; Do not leave any parameter blank, try again."
  }
}

function set-ipaddress {
    Clear-Host
    Write-Host "Availible Interfaces:`n"$interfaces""
    # Aquire information from the user...
        
    [string]$interfaceAlias = Read-Host "Choose an adapter from the list"
    [string]$ipv4Address = Read-Host "Enter the desired IPv4 Address"
    [byte]$prefixLength = Read-Host "Enter the subnet mask in cider notation `nExample: /24, Don't include the '/'"
  
  # Handles errors if parameters are left empty
  try {
    # Disable DHCP on interface
    Set-NetIPInterface -InterfaceAlias $interfaceAlias -Dhcp disabled -ErrorAction SilentlyContinue
    }
  catch {
    Write-Host -ForegroundColor DarkYellow -BackgroundColor Black "An error has occured; Do not leave any parameter blank, try again."
  }
    # Release IP Address, hide output
    ipconfig /release > null
  
  # Handles errors if parameters are left empty
  try {
    # Remove Previous IP address information
    Remove-NetIPAddress -InterfaceAlias $interfaceAlias -Confirm:$false -ErrorAction SilentlyContinue
  }
  catch [CmdletizationQuery_NotFound_InterfaceAlias] {
    Write-Host -ForegroundColor DarkYellow -BackgroundColor Black "An error has occured; Do not leave any parameter blank, try again."
  }
  
  # Error handling to correct to prevent blood if parameter is left empty or an error occurs
  try {
    # Set new IP address information, this is not persistant after reboot
    New-NetIPAddress –InterfaceAlias $interfaceAlias –IPAddress $ipv4Address –PrefixLength $prefixLength -PolicyStore ActiveStore -Confirm:$false -ErrorAction SilentlyContinue > null
  }
  catch {
    Write-Host -ForegroundColor DarkYellow -BackgroundColor Black "Please do not leave any parameters blank! Choose option 5 to reset adapters and try again."
  }
}

function refresh-dhcpAll {
    clear-host
    Write-Host -Verbose -ForegroundColor yellow -BackgroundColor black "Loading, please wait!"
    # Enable/Disable DHCP on interfaces
    Set-NetIPInterface -InterfaceAlias (Get-NetAdapter | ForEach-Object {$_.InterfaceAlias}) -dhcp disable
    Set-NetIPInterface -InterfaceAlias (Get-NetAdapter | ForEach-Object {$_.InterfaceAlias}) -dhcp enable
}

function refresh-allInterface {
    clear-host
    Write-Host -Verbose -ForegroundColor yellow -BackgroundColor black "Loading, please wait!"
    # Enable/Disable DHCP on interfaces
    Set-NetIPInterface -InterfaceAlias (Get-NetAdapter | ForEach-Object {$_.InterfaceAlias}) -dhcp disable
    Set-NetIPInterface -InterfaceAlias (Get-NetAdapter | ForEach-Object {$_.InterfaceAlias}) -dhcp enable
    # Enable/Disable adapters to release any temporary settings
    Disable-NetAdapter -Name * -Confirm:$false
    Enable-NetAdapter -Name * -Confirm:$false
}

function show-menu {
     #Clear screen once
     #clear-host
     Write-Host "Welcome to Tory's NET TOOLS!`n"
     
     # Display the menu while awaiting user input
     while ($userChoice = Read-host -p "Please enter one of the following menu selections:
     
            #1. View Interfaces
            #2. View IP Addresses
            #3. View Default Gateway
            #4. Assign DNS Server
            #5. Assign Static Address
            #6. Refresh DHCP (Disable/Enable)
            #7. Refresh all interfaces (Disable/Enable)
            
            Press ENTER to exit program...
            
            Your Choice" ) {    
            
                #If user choice equals 1...
                if ($userChoice -eq 1) {
                    #call function to view interfaces
                    show-interfaces
                    Pause
                    Clear-Host
                }
                #If user choice equals 2... 
                elseif ($userChoice -eq 2) {                
                        #
                        show-ipdetail
                        #call function to view ip addresses
                        Pause
                        Clear-Host
                }
                #If user choice equals 3...
                elseif ($userChoice -eq 3) {
                        #call function to view default gateway
                        show-defaultgateway
                        Pause
                        Clear-Host
                }
                #If user choice equals 4...
                elseif ($userChoice -eq 4) {
                        #call function set dns server primary and secondary 
                        set-dnsserver
                        Pause
                        Clear-Host
                }  
                #If user choice equals 5...
                elseif ($userChoice -eq 5) {
                        set-ipaddress
                        Pause
                        Clear-Host
                }         
                #If user choice equals 6...  
                elseif ($userChoice -eq 6) {
                        #call function to disable/re-enable dhcp on all adapters
                        refresh-dhcpAll
                        Write-Host "Success!"
                        pause
                        Clear-Host
                }
                #If user choice equals 7...
                elseif ($userChoice -eq 7) {
                        #call function to refresh all interfaces
                        refresh-allInterface
                        Write-Host "Success!"
                        pause
                        Clear-Host
                }    
                #Else...
                else {
                    Write-Host "`nIncorrect, please try again`n`n"
                
                }
            
        }# End while loop 
}

#Begin Program
clear-host
show-menu

    
 
   
    
    

    
       