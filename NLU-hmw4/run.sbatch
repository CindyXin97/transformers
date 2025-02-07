#!/bin/bash
#SBATCH --gres=gpu:1
#SBATCH --mem=16000
#SBATCH --time=0:30:00
#SBATCH --job-name="nlu_hw4"
#SBATCH --mail-user=zz2498@nyu.edu

module purge
module load anaconda3/5.3.1
module load cuda/10.0.130
module load gcc/6.3.0

NETID=jg6193
GLUE_DIR=/scratch/${NETID}/nlu/data
TASK_NAME=BoolQ

source activate /scratch/${NETID}/nlu/env

export PYTORCH_TRANSFORMERS_CACHE=/scratch/${NETID}/nlu/cache
conda install pytorch torchvision -c pytorch
conda update conda
conda install mkl=2018

cd /scratch/${NETID}/nlu/data
wget https://dl.fbaipublicfiles.com/glue/superglue/data/v2/BoolQ.zip
unzip BoolQ.zip

cd /scratch/${NETID}/nlu/code

git clone https://github.com/JasonZhangzy1757/transformers_for_NLU_HW.git
cd transformers_for_NLU_HW
pip install -r ./examples/requirements.txt
pip install boto3 filelock requests tqdm sentencepiece sacremoses tokenizers

export PYTHONPATH=/scratch/${NETID}/nlu/code/transformers_for_NLU_HW/src:$PYTHONPATH

python ./examples/run_glue.py \
    --model_type roberta \
    --model_name_or_path  roberta-base \
    --task_name ${TASK_NAME} \
    --do_train \
    --do_eval \
    --data_dir ${GLUE_DIR}/${TASK_NAME} \
    --max_seq_length 128 \
    --per_gpu_eval_batch_size=8   \
    --per_gpu_train_batch_size=8   \
    --learning_rate 2e-5 \
    --num_train_epochs 3.0 \
    --output_dir /scratch/${NETID}/nlu/${TASK_NAME}_run/ \
    --overwrite_output_dir
