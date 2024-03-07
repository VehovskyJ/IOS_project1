#!/bin/bash
#
# Tests for 1. IOS project [2024]
# author: dzives
# heavily inspired by: pseja
# Usage:
#     (1) Download the gist to your "xtf" directory: click raw ⬆️, copy url, wget url
#     (2) Then (for adding permission):              chmod u+x test_xtf.sh
#     (3) Execute this command in "xtf" directory:   ./test_xtf.sh
#     (4) If any test fails, it will output the difference between the expected result and your output with diff command into the diff folder
#     (4) Debug :D



# color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NORMAL='\033[0m'

# test variables
test_count=0
correct=0

# compile maze.c just in case

rm -rf diff

run_test() {
    local expected_output=${1}
    local args=("${@:2}")
    echo -n -e "$test_count. Running ./xtf"
    for arg in "${args[@]}"; do
        echo -n " \"$arg\""
    done
    echo ""

    local actual_output=$(./xtf "${args[@]}")

    if [[ "$actual_output" == "$expected_output" ]]; then
        echo -e "${GREEN} [OK] ${NORMAL}"
        correct=$((correct + 1))
        test_count=$((test_count + 1))
        return 0
    else
        echo -e "${RED}[FAIL]${NORMAL}"
        mkdir -p diff
        echo -e "$expected_output" > "./diff/$test_count:diff_expected.txt"
        echo -e "$actual_output" > "./diff/$test_count:diff_yours.txt"
        diff "./diff/$test_count:diff_expected.txt" "./diff/$test_count:diff_yours.txt"
        test_count=$((test_count + 1))
        return 1
    fi


}



# tests
echo -e "Trader1;2024-01-15 15:30:42;EUR;-2000.0000\nTrader2;2024-01-15 15:31:12;BTC;-9.8734\nTrader1;2024-01-16 18:06:32;USD;-3000.0000\nCryptoWiz;2024-01-17 08:58:09;CZK;10000.0000\nTrader1;2024-01-20 11:43:02;ETH;1.9417\nTrader1;2024-01-22 09:17:40;ETH;10.9537\n" > cryptoexchange.log

# 0
args=("Trader1" "cryptoexchange.log")
run_test "Trader1;2024-01-15 15:30:42;EUR;-2000.0000
Trader1;2024-01-16 18:06:32;USD;-3000.0000
Trader1;2024-01-20 11:43:02;ETH;1.9417
Trader1;2024-01-22 09:17:40;ETH;10.9537" "${args[@]}"

# 1
args=("list" "Trader1" "cryptoexchange.log")
run_test "Trader1;2024-01-15 15:30:42;EUR;-2000.0000
Trader1;2024-01-16 18:06:32;USD;-3000.0000
Trader1;2024-01-20 11:43:02;ETH;1.9417
Trader1;2024-01-22 09:17:40;ETH;10.9537" "${args[@]}"

# 2
args=("-c" "ETH" "list" "Trader1" "cryptoexchange.log")
run_test "Trader1;2024-01-20 11:43:02;ETH;1.9417
Trader1;2024-01-22 09:17:40;ETH;10.9537" "${args[@]}"

# 3
args=("-c" "GBP" "list" "Trader1" "cryptoexchange.log")
run_test "" "${args[@]}"

# 4
args=("list-currency" "Trader1" "cryptoexchange.log")
run_test "ETH
EUR
USD" "${args[@]}"

# 5
args=("status" "Trader1" "cryptoexchange.log")
run_test "ETH : 12.8954
EUR : -2000.0000
USD : -3000.0000" "${args[@]}"

# 6
args=(-b "2024-01-22 09:17:40" "status" "Trader1" "cryptoexchange.log")
run_test "ETH : 1.9417
EUR : -2000.0000
USD : -3000.0000" "${args[@]}"


# 7
args=(-a "2024-01-15 16:00:00" -b "2024-01-22 09:17:41" "status" "Trader1" "cryptoexchange.log")
run_test "ETH : 12.8954
USD : -3000.0000" "${args[@]}"

# 8
args=("profit" "Trader1" "cryptoexchange.log")
run_test "ETH : 15.4745
EUR : -2000.0000
USD : -3000.0000" "${args[@]}"
if  [ "$?" = "1" ] ; then
    test_count=$((test_count - 1))
    echo Rerunning test "$test_count"
    run_test "ETH : 15.4744
EUR : -2000.0000
USD : -3000.0000" "${args[@]}"
fi

# 9
export XTF_PROFIT=40
args=("profit" "Trader1" "cryptoexchange.log")
run_test  "ETH : 18.0536
EUR : -2000.0000
USD : -3000.0000" "${args[@]}"
if  [ "$?" = "1" ] ; then
    test_count=$((test_count - 1))
    echo Rerunning test "$test_count"
    run_test "ETH : 18.0535
EUR : -2000.0000
USD : -3000.0000" "${args[@]}"
fi
unset XTF_PROFIT

# 10
echo Příklad s více logy
echo -e "Trader1;2024-01-15 15:30:42;EUR;-2000.0000\nTrader2;2024-01-15 15:31:12;BTC;-9.8734\nTrader1;2024-01-16 18:06:32;USD;-3000.0000\n" > cryptoexchange-1.log
echo -e "CryptoWiz;2024-01-17 08:58:09;CZK;10000.0000\n
Trader1;2024-01-20 11:43:02;ETH;1.9417\n
Trader1;2024-01-22 09:17:40;ETH;10.9537\n" > cryptoexchange-2.log
gzip -c cryptoexchange-2.log > cryptoexchange-2.log.gz
rm cryptoexchange-2.log

args=("status" "Trader1" "cryptoexchange-1.log" "cryptoexchange-2.log.gz")
run_test "ETH : 12.8954
EUR : -2000.0000
USD : -3000.0000" "${args[@]}"


# 11
echo "Příklady rozšíření:"
args=("Trader1" "status" "-a" "2024-01-15 16:00:00" "-b" "2024-01-22 09:17:41" "cryptoexchange.log")
run_test "ETH : 12.8954
USD : -3000.0000" "${args[@]}"

# 12
args=("-c" "ETH" "-c" "USD" "Trader1" "cryptoexchange.log")
run_test "Trader1;2024-01-16 18:06:32;USD;-3000.0000
Trader1;2024-01-20 11:43:02;ETH;1.9417
Trader1;2024-01-22 09:17:40;ETH;10.9537" "${args[@]}"

# 13
args=("-c" "ETH" "-c" "EUR" "-c" "GBP" "list-currency" "Trader1" "cryptoexchange.log")
run_test "ETH
EUR" "${args[@]}"

# tests by @uzimonkey

echo "Added tests:"
# 14
args=("list" "Trader1" "cryptoexchange.log")
run_test "Trader1;2024-01-15 15:30:42;EUR;-2000.0000
Trader1;2024-01-16 18:06:32;USD;-3000.0000
Trader1;2024-01-20 11:43:02;ETH;1.9417
Trader1;2024-01-22 09:17:40;ETH;10.9537" "${args[@]}"

# 15 invalid file with space or 2 usernames
args=("list-currency" "Trader1" "Trader 2" "cryptoexchange.log")
run_test "" "${args[@]}"

# 16 invalid file
args=("status" "Trader1" "invalid.log")
run_test "" "${args[@]}"

# 17 no user/
args=("status" "cryptoexchange.log")
run_test "" "${args[@]}"

# 18 2 commands + no user
args=("status" "status" "cryptoexchange.log")
run_test "" "${args[@]}"

# 19 2 commands
args=("status" "list" "Trader1" "cryptoexchange.log")
run_test "" "${args[@]}"

# 20 duplicate files
# WARNING UNDEFINED BEHAVIOR (logs in files should be in chronological order, the tests shouldn't have this)
args=("list" "Trader1" "cryptoexchange.log" "cryptoexchange.log")
run_test "Trader1;2024-01-15 15:30:42;EUR;-2000.0000
Trader1;2024-01-16 18:06:32;USD;-3000.0000
Trader1;2024-01-20 11:43:02;ETH;1.9417
Trader1;2024-01-22 09:17:40;ETH;10.9537
Trader1;2024-01-15 15:30:42;EUR;-2000.0000
Trader1;2024-01-16 18:06:32;USD;-3000.0000
Trader1;2024-01-20 11:43:02;ETH;1.9417
Trader1;2024-01-22 09:17:40;ETH;10.9537" "${args[@]}"
if  [ "$?" = "1" ] ; then
    echo -e "${RED}WARNING UNDEFINED BEHAVIOR${NORMAL}"
fi

# args=("list" "Trader1" "cryptoexchange.log" "cryptoexchange.log")
# run_test "" "${args[@]}"

# 21 duplicate files
# WARNING UNDEFINED BEHAVIOR (logs in files should be in chronological order, the tests shouldn't have this)
args=("list" "Trader1" "cryptoexchange.log" "cryptoexchange.log" "cryptoexchange.log")
run_test "Trader1;2024-01-15 15:30:42;EUR;-2000.0000
Trader1;2024-01-16 18:06:32;USD;-3000.0000
Trader1;2024-01-20 11:43:02;ETH;1.9417
Trader1;2024-01-22 09:17:40;ETH;10.9537
Trader1;2024-01-15 15:30:42;EUR;-2000.0000
Trader1;2024-01-16 18:06:32;USD;-3000.0000
Trader1;2024-01-20 11:43:02;ETH;1.9417
Trader1;2024-01-22 09:17:40;ETH;10.9537
Trader1;2024-01-15 15:30:42;EUR;-2000.0000
Trader1;2024-01-16 18:06:32;USD;-3000.0000
Trader1;2024-01-20 11:43:02;ETH;1.9417
Trader1;2024-01-22 09:17:40;ETH;10.9537" "${args[@]}"
if  [ "$?" = "1" ] ; then
    echo -e "${RED}WARNING UNDEFINED BEHAVIOR${NORMAL}"
fi

# args=("list" "Trader1" "cryptoexchange.log" "cryptoexchange.log" "cryptoexchange.log")
# run_test "" "${args[@]}"

# 22
args=("cryptoexchange.log")
run_test "" "${args[@]}"

# 23
args=("-c" "ETH" "profit" "Trader1" "cryptoexchange.log" "cryptoexchange-2.log.gz")
run_test "ETH : 30.9490" "${args[@]}"
if  [ "$?" = "1" ] ; then
    test_count=$((test_count - 1))
    echo Rerunning test "$test_count"
    run_test "ETH : 30.9489" "${args[@]}"
fi

# 24
args=("-a" "2024-01-21 15:29:29" "status" "Trader1" "cryptoexchange.log")
run_test "ETH : 10.9537" "${args[@]}"

# 25
args=("-b" "2024-01-21 15:29:29" "status" "Trader1" "cryptoexchange.log")
run_test "ETH : 1.9417
EUR : -2000.0000
USD : -3000.0000" "${args[@]}"

# 26
args=("-a" "2024-01-25 15:29:29" "status" "Trader1" "cryptoexchange.log")
run_test "" "${args[@]}"

# 27 invalid date format
args=("-a" "10-2024-21 15:29:29" "status" "Trader1" "cryptoexchange.log")
run_test "" "${args[@]}"

# 28 invalid date format
args=("-a" "2024-01-21 15:300:29" "-b" "2024-01-21 15:29:29" "status" "Trader1" "cryptoexchange.log")
run_test "" "${args[@]}"

# 29 no trimming/rounding re-check needed
export XTF_PROFIT=0
args=("-a" "2024-01-21 15:29:29" "profit" "Trader1" "cryptoexchange.log")
run_test "ETH : 10.9537" "${args[@]}"
unset XTF_PROFIT

# more tests by @dzives

# 30 mutliple files profit
args=("profit" "Trader1" "cryptoexchange.log" "cryptoexchange-2.log.gz")
run_test "ETH : 30.9490
EUR : -2000.0000
USD : -3000.0000" "${args[@]}"
if  [ "$?" = "1" ] ; then
    test_count=$((test_count - 1))
    echo Rerunning test "$test_count"
    run_test "ETH : 30.9489
EUR : -2000.0000
USD : -3000.0000" "${args[@]}"
fi

# 31 profit >= 100
export XTF_PROFIT=120
args=("profit" "Trader1" "cryptoexchange.log")
run_test "ETH : 28.3699
EUR : -2000.0000
USD : -3000.0000" "${args[@]}"
if  [ "$?" = "1" ] ; then
    test_count=$((test_count - 1))
    echo Rerunning test "$test_count"
    run_test "ETH : 28.3698
EUR : -2000.0000
USD : -3000.0000" "${args[@]}"
fi
unset XTF_PROFIT

# 32 space in name
cp cryptoexchange.log "crypto exchange.log"
args=("list-currency" "Trader1" "crypto exchange.log")
run_test "ETH
EUR
USD" "${args[@]}"

# 33 space in name of gzip
gzip -c cryptoexchange.log > "crypto exchange.log.gz"
args=("list-currency" "Trader1" "crypto exchange.log.gz")
run_test "ETH
EUR
USD" "${args[@]}"

# 34 long currency (4 chars)
args=( "-c" "ABCD" "list" "Trader1" "cryptoexchange.log")
run_test "" "${args[@]}"

# 35 short currency (2 chars)
args=( "-c" "AB" "list" "Trader1" "cryptoexchange.log")
run_test "" "${args[@]}"

# 36 2 times -a
args=("-a" "2024-01-25 15:29:29" "-a" "2024-01-25 16:29:29" "Trader1" "cryptoexchange.log")
run_test "" "${args[@]}"

# 37 2 times -b
args=("-b" "2024-01-25 15:29:29" "-b" "2024-01-25 16:29:29" "Trader1" "cryptoexchange.log")
run_test "" "${args[@]}"





# print test results
if [[ "$correct" == "$test_count" ]]; then
    echo -e "\nPassed $correct / $test_count 🤓"
else
    echo -e "\nPassed $correct / $test_count"
fi

# remove temp test files
# if you want individual tests comment line with the test you want to keep
# make sure to later uncomment tho :D

rm cryptoexchange.log
rm cryptoexchange-2.log.gz
rm cryptoexchange-1.log
rm "crypto exchange.log"
rm "crypto exchange.log.gz"
