FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y gnudatalanguage sudo xorg-dev libcfitsio-dev libcanberra-gtk-module

COPY PRO/*.pro /
COPY generate_many_convolved_ideal_images_for_MachineLearning_6_GDLversion.pro /
COPY justco* /
COPY dummy* /

CMD ["gdl", "go.pro"]

