#!/bin/bash

command=$1

batch_size=128
resnet_size=50
export TF_FORCE_GPU_ALLOW_GROWTH=true
# 设置显存限制 tensorflow/core/grappler/optimizers/memory_optimizer.cc:1018
export GPU_MEM_LIMIT=5
# unset GPU_MEM_LIMIT

# 手工设置batch_size大小计算cost tensorflow/core/grappler/costs/op_level_cost_estimator.cc:238
export GPU_MEM_BATCH_SIZE=$batch_size
# unset GPU_MEM_BATCH_SIZE

# 获取唯一的bfc alloc
export TF_GPU_VMEM=0

unset TF_CPP_VMODULE

export TF_DUMP_GRAPH_PREFIX=/root/models/official/r1/resnet

unset TURN_OFF_SWAP
# export TURN_OFF_SWAP=true


# TF_CPP_VMODULE=memory_optimizer=4,graph_memory=3,direct_session=3,log_memory=0,virtual_cluster=3,bfc_allocator=0,analytical_cost_estimator=3,virtual_scheduler=3,op_level_cost_estimator=0  CUDA_VISIBLE_DEVICES=0  python train.py --batch_size=4096 --steps=1200

# TF_CPP_VMODULE=memory_optimizer=5  CUDA_VISIBLE_DEVICES=0  python -u train.py --batch_size=8192 --steps=500 --tf --inter=1 --timeline=100

result=$(echo $command | grep "swap")
if [[ $command =~ "swap" ]]
then
    echo swap
    export MEM_OPT_SWAP=true
    TF_CPP_VMODULE=memory_optimizer=3,gpu_util=0 CUDA_VISIBLE_DEVICES=0  python -u imagenet_main.py --batch_size=$batch_size  --data_dir=/root/dataset/ILSVRC2012/tf_records    --resnet_size=$resnet_size 
elif [[ $command =~ "force" ]]
then
    echo force
    export MEM_OPT_SWAP=force
    TF_CPP_VMODULE=memory_optimizer=3 CUDA_VISIBLE_DEVICES=0 python -u imagenet_main.py --batch_size=$batch_size  --data_dir=/root/dataset/ILSVRC2012/tf_records    --resnet_size=$resnet_size 
else 
    echo noswap
    export MEM_OPT_SWAP=false
    TF_CPP_VMODULE=memory_optimizer=0,gpu_util=0 CUDA_VISIBLE_DEVICES=0  python -u imagenet_main.py --batch_size=$batch_size  --data_dir=/root/dataset/ILSVRC2012/tf_records    --resnet_size=$resnet_size 
fi