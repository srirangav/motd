#!/usr/bin/python3
#
# harmonic.py - calculate the sum of the harmonic sequence in bases
#               greater than 10 (maximum supported base is 36)
#
# Usage: harmonic.py [base] [no. of terms]
#
# Based on: https://www.johndcook.com/blog/2024/08/29/strange-harmonic-series/

import sys

# f(n, b) - return the n-th term in base b

def f(n, b):
    return int(str(n), b)

# first argument (if given) is the base, which must be between 11 and 36
# the default is 11

try:
    base=int(sys.argv[1])
except IndexError:
    base=11

if (base <= 10):
    print("ERROR: base must be at least 11")
    exit(1)
elif (base > 36):
    print("ERROR: base must be less than 36")
    exit(1)

# second argument is the number of terms to sum, which must be at least 1
# the default is 1000

try:
    terms=int(sys.argv[2])
except IndexError:
    terms=1000
if (terms <= 0):
    print("ERROR: number of terms must be at least 1")
    exit(1)

harmonic=0
i=1
while i <= terms:
    harmonic += 1/f(i, base)
    i += 1
print(harmonic)
exit(0)
