FROM google/cloud-sdk:latest

RUN apt-get update

WORKDIR /root
ADD cloudtools_bashrc .bashrc

RUN git clone https://github.com/ahmetb/kubectx kubectx
RUN chmod +x kubectx/kubectx
RUN chmod +x kubectx/kubens
RUN mkdir bin
RUN mv kubectx/kubectx $HOME/bin/
RUN mv kubectx/kubens $HOME/bin/

RUN curl -o .kubectl_aliases https://raw.githubusercontent.com/ahmetb/kubectl-alias/master/.kubectl_aliases
RUN touch $HOME/.bashrc
RUN echo "[ -f ~/.kubectl_aliases ] && source ~/.kubectl_aliases" >> $HOME/.bashrc
RUN /bin/bash -c "source $HOME/.bashrc"

ENV ISTIO_VERSION 1.0.6
RUN curl -L https://git.io/getLatestIstio | ISTIO_VERSION=$ISTIO_VERSION sh -

RUN apt-get install wget jq nano vim sudo unzip apt-transport-https lsb-release software-properties-common dirmngr apache2-utils man locate tcpdump traceroute telnet -y

RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
RUN unzip awscli-bundle.zip
RUN ./awscli-bundle/install -b ~/bin/aws

RUN curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
RUN mv /tmp/eksctl /usr/bin

RUN curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator
RUN chmod +x aws-iam-authenticator
RUN cp aws-iam-authenticator /usr/bin/

RUN curl -o heptio-authenticator-aws https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.3.0/heptio-authenticator-aws_0.3.0_linux_amd64
RUN chmod +x heptio-authenticator-aws
RUN mv heptio-authenticator-aws /usr/bin/

RUN curl -Lo kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
RUN chmod +x ./kops
RUN mv ./kops /usr/bin/

ENV AZ_REPO stretch
RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list
RUN apt-key --keyring /etc/apt/trusted.gpg.d/Microsoft.gpg adv --keyserver packages.microsoft.com --recv-keys BC528686B50D79E339D3721CEB3E94ADBE1229CF
RUN apt-get update
RUN apt-get install azure-cli

RUN ln -sf /usr/bin/python3.5 /usr/bin/python

RUN curl -o go1.12.linux-amd64.tar.gz https://dl.google.com/go/go1.12.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf go1.12.linux-amd64.tar.gz
ENV PATH "$PATH:/usr/local/go/bin:$HOME/go/bin"

RUN go get -u github.com/rakyll/hey
RUN go get fortio.org/fortio

RUN curl -o terraform_0.11.11_linux_amd64.zip https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip
RUN unzip terraform_0.11.11_linux_amd64.zip
RUN mv terraform $HOME/bin/.

RUN curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
RUN chmod 700 get_helm.sh
RUN /bin/bash -c "./get_helm.sh &> /dev/null"
