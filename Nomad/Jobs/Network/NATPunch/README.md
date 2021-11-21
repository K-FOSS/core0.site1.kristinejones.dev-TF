# K-FOSS/core0.site1.kristianjones.dev NATPunch Network Stack

The NATPunch stack contains services that allow for punching holes through NAT and creating tunnels, relays, and zero trust human, and Machine to Machine identities without risking security, nor comprimising "privacy" we only need to attach an "entity" to a "user" not a person.

For more information on treating a user/client and a person/machine/source seperate without using that connection for personal/capital gain SEE (TODO)

## Services

### CoTURN

CoTurn provides [STUN](https://en.wikipedia.org/wiki/STUN), [TURN](https://en.wikipedia.org/wiki/Traversal_Using_Relays_around_NAT), [ICE](https://en.wikipedia.org/wiki/Interactive_Connectivity_Establishment) to provide a full stack, generic/standard method of obtaining information needed for direct P2P connections, or using secure anonomys information to create a tunnel between the end clients if direct connections fail.

#### Uses

##### Networking

###### VPN

https://github.com/wiretrustee/wiretrustee


###### VoIP/SIP/Asterisk

https://wiki.asterisk.org/wiki/display/AST/Interactive+Connectivity+Establishment+%28ICE%29+in+Asterisk

###### P2P Communications

https://jitsi.github.io/handbook/docs/devops-guide/turn

https://help.nextcloud.com/t/installing-stun-turn-server/25549

