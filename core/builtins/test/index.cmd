:: Name: test
:: Description: A command for testing.
:: Usage: test
:: Author: Beef

call %core%\api\owoifyString.cmd "Hello! :flushed: I like you, Ethan. You are very social."
setlocal DisableDelayedExpansion
echo %stringResult%