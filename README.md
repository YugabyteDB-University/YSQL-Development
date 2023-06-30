<div style="width:100%; background-color: #000041"><a target="_blank" href="http://university.yugabyte.com"><img src="assets/YBU_Logo.png" /></a></div>

# YSQL Development

[YugabyteDB](https://www.yugabyte.com/) is the leading open source, distributed SQL database. The database has two APIs: YCQL and YSQL.

This repository is a lab resource in the free, **YugabyteDB YSQL Development** course from Yugabyte University.

> **YugabyteDB YSQL Development**
>
> Enroll for **FREE** at ...
> [Yugabyte University](https://university.yugabyte.com/).
>

---

To start the Gitpod environment, which is also free to use, select the link below. All you need is a Github account.

[![](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/YugabyteDB-University/YSQL-Development)

Gitpod is an on-demand developer environment for a GitHub, Git, or BitBucket workspace. It's super easy to use, offers 50 hours of free use per month, and only requires a chromium based browser.

Using Gitpod, you can run the notebook files in an on-demand VS Code, browser based environment. 😎

This repository contains the notebook files for YSQL Development, a free course that is soon-to-be available at [university.yugabyte.com](https://university.yugabyte.com).

Using Gitpod, you can run the notebook files in an on-demand VS Code, browser based environment.


## New to Github and Gitpod? Here's how to start...

- First, create a Github account. It's free. [https://github.com/join](https://github.com/join)
Then, in a browser, open the Gitpod link for the GitHub repository. It's a prefix -  gitpod.io/# - and entire URL for the repository. For example, `gitpod.io/#https://github.com/gitpod-io/websit`e
- Optionally, to make this a seamless one click installation, install the Gitpod browser extension. To learn more about the extension, see [https://www.gitpod.io/docs/browser-extension](https://www.gitpod.io/docs/browser-extension)
- You will need to authorize Gitpod to use your GitHub account. Select Authorize gitpod.io.
- Select your default editor, VS Code Browser. Select Continue.
- Depending on the image configuration, it may take a few minutes for the image to build and to deploy to workspace.


### FAQS

**Will this repository or similar be made available at github.com/yugabyte?**
- Currently, no. Gitpod is not available for the Yugabyte account.

**What is Gitpod?**
- Gitpod is a free developer service that makes it easy for maintainers to automate any non-executable setup instructions as code. Gitpod is part of Github.com. Gitpod launches pre-configured containers for a given project. 
  
**How much does Gitpod cost?**
- Gitpod is free for the first 50 hours of usage for a given month. To learn more, see [https://www.gitpod.io/pricing](https://www.gitpod.io/pricing).

**How can I sign up for Gitpod?**
- Sign up for a Github.com account.
- To install the Gitpod browser extension, check out [https://www.gitpod.io/docs/quickstart#installing-the-gitpod-browser-extension](https://www.gitpod.io/docs/quickstart#installing-the-gitpod-browser-extension).

**How do I start?**
- Simply select this link: [https://gitpod.io/#https://github.com/YugabyteDB-University/YSQL-Development](https://gitpod.io/#https://github.com/YugabyteDB-University/YSQL-Development)

**Why does it take 5 minutes to start up?**
- Gitpod builds a docker image for VS Code, related extensions, and YugabyteDB. This takes a few minutes. However, after your image is created, subsequent launches will be much faster.

**Where can I find help and support?**
- You can ask questions in the discussion forum for this lab in the course player at Yugabyte University. Enroll for **FREE** at [Yugabyte University](https://university.yugabyte.com/).

---
### Release notes
Notes regarding updates to this repository.
- 2023.06.30
  - Update for 2.19
- 2023.05.10
  - added more index uses cases 
  - add GIN indexes
  - add built-in functions to geo-partitioning
- 2023.05.07
  - Update for 2.17.3
  - Replace `curl` with `wget` for `fn_yb_tserver_metrics_snap()` in `util_ybtserver_metrics.sql`. This works in Gitpod now.
- 2023.04.20
  - Update notebooks with emojis
  - Added Kill connections with drop of databases
