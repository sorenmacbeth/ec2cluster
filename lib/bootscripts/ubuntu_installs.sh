#!/bin/bash
# ubuntu MPI cluster installs and config https://help.ubuntu.com/community/MpichCluster
apt-get -y install build-essential
apt-get -y install libboost-serialization-dev
apt-get -y install libexpat1-dev
apt-get -y install libopenmpi1 openmpi-bin openmpi-common
apt-get -y install libopenmpi-dev

su - elasticwulf -c "
cat <<EOF >> /home/elasticwulf/hello.c
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
EOF"

# Quick test of MPI
su - elasticwulf -c "mpicc /home/elasticwulf/hello.c -o /home/elasticwulf/hello" 
### check number of processors available
# cat /proc/cpuinfo 
su - elasticwulf -c "mpirun --mca btl ^openib -np 2 /home/elasticwulf/hello"

# ruby and ruby gems...
apt-get -y install ruby-full build-essential
wget http://rubyforge.org/frs/download.php/45905/rubygems-1.3.1.tgz
tar xzvf rubygems-1.3.1.tgz
cd rubygems-1.3.1
sudo ruby setup.rb
sudo ln -s /usr/bin/gem1.8 /usr/bin/gem
sudo gem update --system

gem install right_http_connection --no-rdoc --no-ri
gem install right_aws --no-rdoc --no-ri
gem install activeresource --no-ri --no-rdoc

# TODO: will we have a client gem???

# then we run a "GET" to get all the job properties for that id on the master node.
# we can fetch the indicated files from s3, (the buckets should be owned by the same AWS key)
# need to trigger /nextstep at start of job
# then run the mpi command / bash script indicated,
# finally, we send the output files up to the s3 bucket indicated
# when that is complete, we trigger nextstep again.

#  s3.put(bucket_name, 'S3keyname.forthisfile',  File.open('localfilename.dat'))


