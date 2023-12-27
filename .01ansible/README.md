to run playbooks run:

ansible-playbook -i hosts ./playbooks/temperatures_of_hosts.yml --ask-vault-pass --extra-vars '@sudo_pass.yml'