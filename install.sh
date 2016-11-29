#!/bin/bash
COL='\033[0;1;36m'
NC='\033[0m'

echo -e "\n${COL}Updating pip${NC}"
pip install -U pip

echo -e "\n${COL}Installing Tensorflow${NC}"
pip install tensorflow

echo -e "\n${COL}Installing keras${NC}"
pip install keras

echo -e "\n${COL}Installing h5py${NC}"
pip install h5py

echo -e "\n${COL}Updating bundler${NC}"
gem update bundler

echo -e "\n${COL}Installing Ruby dependancies${NC}"
bundle install

echo -e "\n${COL}Building and installing the project${NC}"
bundle exec rake install

echo -e "\n${COL}Done!${NC}"
