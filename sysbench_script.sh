#!/bin/bash
#
#
# Date: 2020-08-05
#

# 获取CPU的线程数
CPU_NUM=$(cat /proc/cpuinfo | grep 'processor' | wc -l)

# sysbench的通用参数
# --threads - 启用线程数量
# --events - 测试的次数，默认值0，不限制；如果时间达到但还有未完成的次数，那么就会停止
# --time - 测试时间，单位是秒，默认值是10；达到时间就停止，如果次数先到达而时间有剩余，同样会停止

# 测试CPU
# --cpu-max-prime - 每次循环生成多少个质数，最小的质数是2，例如生成3个质素，那么一次循环会生成2，3，5共3个质数。
sysbench cpu --cpu-max-prime=20000 --threads=$CPU_NUM --events=0 --time=10 run

# 测试MEMORY
# --memory-total-size=100G - 测试时使用的数据总量大小，如果加上--time参数，那么时间到了，即使没有达到测试的数据总量，也会停止。
# --memory-access-mode=rnd - memory access mode {seq,rnd} [seq],内存访问模式，包括seq,rnd两种模式，默认为seq
# --memory-oper=write - 内存操作的类型，包括read, write, none，默认为write
# --memory-scope=global - 内存访问的范围，包括全局和本地范围，默认为global
sysbench memory --memory-block-size=4k --memory-total-size=100G --memory-scope=global --memory-oper=write --memory-access-mode=rnd --threads=$CPU_NUM run

# 测试THREADS
# --thread-yields=100 - number of yields to do per request [1000],指定每个请求的压力，默认为1000
# --thread-locks=4 - number of locks per thread [8],指定每个线程的锁数量，默认为8
# --time=10 - 可以加上测试时间。因为默认会加上这个参数，且值为10秒
# --events=N - 当然也可以用这个参数设置测试次数。 
sysbench threads --threads=$CPU_NUM --thread-yields=100 --thread-locks=4 --time=10 run

# 测试MUTEX
# mutex请求的性能与CPU主频及物理CPU个数有关
# --mutex-num=1000 total - size of mutex array [4096],数组互斥的总大小。默认是4096
# --mutex-locks=100000 - number of mutex locks to do per thread [50000],每个线程互斥锁的数量。默认是50000
# --mutex-loops=10000 - 内部互斥锁的空循环数量。默认是10000
sysbench mutex --threads=$CPU_NUM --mutex-num=1000 --mutex-locks=100000 --mutex-loops=10000 run

# 测试FILE IO
# --file-async-backlog=N - number of asynchronous operatons to queue per thread [128]，每一个线程将要执行的异步操作排队的长度
# --file-extra-flags=direct - 文件读写模式，{sync,dsync,direct}，默认是空，即--file-extra-flags=""
# --file-io-mode - {sync,async,mmap} [sync]，选择aync，即可确保libaio起效
# --file-fsync-freq=0 - 在发出这个参数指定数量的请求之后，执行fsync()，将内存中已修改的文件数据同步至存储设备中。若取值为0，则表示不使用fsync()（默认值为100）。
# --file-fsync-all=[on|off] - 每次写操作之后，执行fsync()（默认值为off）。
# --file-fsync-end=[on|off] - 在测试结束时，执行fsync()（默认值为on）。
# --file-fsync-mode=STRING - 同步数据时，使用哪种方法，可选的值有fsync、fdatasync（默认值为fsync）。
# --file-rw-ratio=N - 进行读写综合测试时，读写操作的比率（默认值为1.5）。
# --file-merged-requests=N - 如果可能，最多合并由这个参数指定数量的IO请求。若取值为0，则表示不会合并请求（默认值为0）。

#sysbench fileio --threads=$CPU_NUM --file-num=128 --file-block-size=16384 --file-total-size=2G --file-test-mode=rndrw --file-io-mode=sync --file-extra-flags="" --file-fsync-freq=100 --file-fsync-all=off --file-fsync-end=on --file-fsync-mode=fsync --file-merged-requests=0 --file-rw-ratio=1.5 prepare

#sysbench fileio --threads=$CPU_NUM --file-num=128 --file-block-size=16384 --file-total-size=2G --file-test-mode=rndrw --file-io-mode=sync --file-extra-flags="" --file-fsync-freq=100 --file-fsync-all=off --file-fsync-end=on --file-fsync-mode=fsync --file-merged-requests=0 --file-rw-ratio=1.5 run

sysbench fileio --threads=$CPU_NUM --file-num=128 --file-block-size=16384 --file-total-size=2G --file-test-mode=rndrw --file-io-mode=async --file-async-backlog=128 --file-extra-flags=direct --file-fsync-freq=0 --file-fsync-all=off --file-fsync-end=on --file-fsync-mode=fsync --file-merged-requests=0 --file-rw-ratio=1.5 prepare

sysbench fileio --threads=$CPU_NUM --file-num=128 --file-block-size=16384 --file-total-size=2G --file-test-mode=seqwr --file-io-mode=async --file-async-backlog=128 --file-extra-flags=direct --file-fsync-freq=0 --file-fsync-all=off --file-fsync-end=on --file-fsync-mode=fsync --file-merged-requests=0 --file-rw-ratio=1.5 run

sysbench fileio --threads=$CPU_NUM cleanup

