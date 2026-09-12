2/x: CroLingo

As written, I had started to gather all ideas and document what we want. Of course, there exist magic tools which transform unstructured input into well defined requirements and which help you to make them conflict free, unambiguous, atomic, feasible and verifiable. Yada yada, you know the drill.
Then the development started, we have a first MVP (minimum viable product) now, as Android release package and Linux Desktop build. The first content is added, so the first user feedback could be gathered today. I have to admit, offering an app with well known competitors yields a lot "oh, but here it should behave like this" .. anyway, input from the target audience is really dear to me. So we have now plenty more things to implement and some to adjust. But we did not experience a single crash or logic deadlock.
And some users could already learn some new words.

I've added on-device screenshots from one of the recent builds. If you want the hands-on-experience, go to https://github.com/marcelpetrick/CroLingo/releases/tag/v0.0.40

I'll keep you updated what comes next. 🇭🇷 ❤️ 🇩🇪




2/x: 𝐂𝐫𝐨𝐋𝐢𝐧𝐠𝐨

As written, I had started to gather all ideas and document what we want. Of course, there exist magic tools which transform unstructured input into well-defined #requirements and which help you to make them conflict-free, unambiguous, atomic, feasible and verifiable. Yada yada, you know the drill.

Then the development started, and we have a first #MVP (minimum viable product) now, as an Android release package and Linux Desktop build. The first content has been added, so the first user feedback could be gathered today. I have to admit, offering an app with well-known competitors yields a lot of "oh, but here it should behave like this" ... anyway, input from the target audience is really dear to me. So we now have plenty more things to implement and some to adjust. But we did not experience a single crash or logic deadlock.

✨ 𝐀𝐧𝐝 𝐬𝐨𝐦𝐞 𝐮𝐬𝐞𝐫𝐬 𝐜𝐨𝐮𝐥𝐝 𝐚𝐥𝐫𝐞𝐚𝐝𝐲 𝐥𝐞𝐚𝐫𝐧 𝐬𝐨𝐦𝐞 𝐧𝐞𝐰 𝐰𝐨𝐫𝐝𝐬. ✨

I've added on-device screenshots from one of the recent builds. If you want the hands-on experience, go to https://github.com/marcelpetrick/CroLingo/releases/tag/v0.0.40

I'll keep you updated on what comes next. 🇭🇷 ❤️ 🇩🇪

-----------


3/x: 𝐂𝐫𝐨𝐋𝐢𝐧𝐠𝐨: pipelines

In a feature-driven world, support-software rarely gets the stage it deserves. Ask a stakeholder what a pipeline is and get 🙃 ..  which is sad. Because how else do you want to verify it you built it correctly?

Anyway: automated testing and linting is always part of my process. From day one - not in the final stages. Of course, you should have at least a tiny build-able fragment of your project, but the earlier you add automation, the better. I usually run with local and continuous integration pipelines.
This project is hosted on GitHub, so I went with GitHub actions for the CI. We have 20 named pipeline stages which form a single commit gate. "Cheap" ones like linting and format checks run before the more "expensive" ones, which need a build. 129 automated tests are done, which cover 98% of the code. Together with the 30 unit and widget tests and a real-target integration suite we have fitting coverage. The local version runs as pre-commit hook, the GitHub one is also capable of doing the releases. And so far I made six public releases.
Also, Dependabot is integrated, so if I would miss the release of any dependency, then this neat little bot would create an automatic PR (pull-request) for me. 🐦‍⬛

The pipeline turns engineering expectations into executable policy. 𝐈𝐭 𝐰𝐨𝐧'𝐭 𝐛𝐮𝐢𝐥𝐝 𝐨𝐫 𝐩𝐚𝐬𝐬, 𝐲𝐨𝐮 𝐜𝐚𝐧'𝐭 𝐫𝐞𝐥𝐞𝐚𝐬𝐞. 𝐒𝐢𝐦𝐩𝐥𝐞 𝐚𝐬 𝐭𝐡𝐚𝐭.

If you want to give this Croatian-German-language learning app a try, download the package from https://github.com/marcelpetrick/CroLingo/releases/tag/v0.0.63 and run it on your Android phone.
Have fun and enjoy learning!

I'll keep you updated on what comes next. 🇭🇷 ❤️ 🇩🇪

#continuousIntegration #continuousDeployment #pipelines #automation

----------

3/x: 𝐂𝐫𝐨𝐋𝐢𝐧𝐠𝐨: SBOMs and CVEs

application saftey and security the the word of the year. The cyber resiluience act as framework for risk reduction is in place. so having a fetted proper SDLC and good infrastrcuutre, like the pipeline-tooling, I showcased yesterday, helps. Aprt from the proper mindeset for everyone involved.

so the pipelines can create us some sBIOM, which can bthen be used to check against databases with known exploitable software-issues (also caled CVEs).

people like alex sänn could definitley tell more about this. but i wanted to show this seprare from the pipeline topic, because most people zone out after too depp technical details.
