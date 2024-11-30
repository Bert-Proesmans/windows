#Requires -RunAsAdministrator

# This resets the windows store + store cache.
# Wait for this process to complete asynchronously
#
# WARN; This command requires internet connection
#
# NOTE; The windows app store is not necessary unless you want a UI frontend!
# NOTE; The appx mechanism embedded in windows perfectly works without the windows store app.
wsreset -i
