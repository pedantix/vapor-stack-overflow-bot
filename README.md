<p align="center">
    <img src="https://user-images.githubusercontent.com/1342803/36623515-7293b4ec-18d3-11e8-85ab-4e2f8fb38fbd.png" width="320" alt="API Template">
    <br>
    <br>
    <a href="http://docs.vapor.codes/3.0/">
        <img src="http://img.shields.io/badge/read_the-docs-2196f3.svg" alt="Documentation">
    </a>
    <a href="https://discord.gg/vapor">
        <img src="https://img.shields.io/discord/431917998102675485.svg" alt="Team Chat">
    </a>
    <a href="LICENSE">
        <img src="http://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
    </a>
    <a href="https://circleci.com/gh/vapor/api-template">
        <img src="https://circleci.com/gh/vapor/api-template.svg?style=shield" alt="Continuous Integration">
    </a>
    <a href="https://swift.org">
        <img src="http://img.shields.io/badge/swift-4.1-brightgreen.svg" alt="Swift 4.1">
    </a>
</p>


# Problem & Solution

The problem the Vapor community is having is that we have a lot of tribal
knowledge that is not being shared with the world. Questions in Discord are
asked and answered but as Discord is a continuous conversation these answers are
lost to senescence. The Vapor community of course does not want to function on
tribal knowledge that is time dependent, Stack Overflow seems like a potential
means of storing answers to common problems that have not been rolled into docs
or official guides and maybe do not belong there for one reason or another.
There are already questions being asked and going unanswered on Stack Overflow
so we need a way of communicating to the "Vapor Tribe" the request for
information. The natural solution to this seems to be building a bot that posts
vapor tagged questions to a Discord channel. Further we could promote a
community effort to answer Stack Overflow questions and acceptance via the
awarding of pennies.

# Approach

The APIs for Discord and Stack Overflow are very straight forward once ever 1
minute a request can look 1 minute backwards on Stack Overflow on a tag of
interest(initially "vapor", "vapor3") and if "new questions" are found they channel
be posted via a webhook to Discord.

### Reference:

Stack Overflow: https://api.stackexchange.com/docs/questions#fromdate=2018-07-20&order=desc&sort=activity&tagged=vapor&filter=default&site=stackoverflow&run=true

Discord:
https://discordapp.com/developers/docs/resources/webhook

# Dependencies
An authorized user on Vapor Discord will have too create a token for the webhook.
