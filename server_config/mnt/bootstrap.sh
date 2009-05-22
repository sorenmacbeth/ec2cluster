#!/bin/bash
#
# ubuntu MPI cluster installs and config https://help.ubuntu.com/community/MpichCluster
#
apt-get -y update
apt-get -y upgrade

useradd -d /home/elasticwulf -m elasticwulf
usermod -G admin elasticwulf

apt-get -y install build-essential
apt-get -y install libboost-serialization-dev
apt-get -y install libexpat1-dev
apt-get -y install libopenmpi1 openmpi-bin openmpi-common
apt-get -y install libopenmpi-dev

cat <<EOF >> /mnt/hello.c
#include <stdio.h>
#include <mpi.h>

int main(int argc, char *argv[]) {
  int numprocs, rank, namelen;
  char processor_name[MPI_MAX_PROCESSOR_NAME];

  MPI_Init(&argc, &argv);
  MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Get_processor_name(processor_name, &namelen);

  printf("Process %d on %s out of %d\n", rank, processor_name, numprocs);

  MPI_Finalize(); 
  }
EOF

mpicc /mnt/hello.c -o /mnt/hello 

### check processors available
# cat /proc/cpuinfo 
mpirun --mca btl ^openib -np 2 hello




