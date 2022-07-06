<h3 align="center">
    <img width="300" src="https://2wz2rk1b7g6s3mm3mk3dj0lh-wpengine.netdna-ssl.com/wp-content/uploads/2018/08/kinetica_logo.svg" alt="Kinetica Logo"/>
</h3>
<h2 align="center">The database for time and space</h2>
<h3 align="center">
    <a href="https://www.kinetica.com/">Website</a>
    <span> | </span>
    <a href="https://docs.kinetica.com/7.1/">Docs</a>
    <span> | </span>
    <a href="https://docs.kinetica.com/7.1/api/">API Docs</a>
    <span> | </span>
    <a href="https://join.slack.com/t/kinetica-community/shared_invite/zt-1bt9x3mvr-uMKrXlSDXfy3oU~sKi84qg">Community Slack</a>
    
</h3>
<h3 align="center">
<img src="https://2wz2rk1b7g6s3mm3mk3dj0lh-wpengine.netdna-ssl.com/wp-content/uploads/2022/02/modern_architecture_04.gif"></img>
</h3>

This project contains **fully reproducible examples** of using Kinetica. Kinetica is a really fast, scalable cloud database for real-time analysis on large and streaming datasets. The developer edition of Kinetica is free and there are free tiers available on Azure and AWS as well.

<h3 align='center'>
<img src='https://2wz2rk1b7g6s3mm3mk3dj0lh-wpengine.netdna-ssl.com/wp-content/uploads/2022/06/workbench_screenshot.png'>
</h3>

# How to run these examples
Each folder in this repo contains a fully reproducible example that uses either SQL or other supported languages (Python, Java, Javascript etc.).

### SQL workbooks
A majority of the examples in this repo use interactive SQL workbooks. The easiest way to download a workbook without the entire repo is to access the raw file and then right click to save as a JSON file on your machine.
![](/workbook_dl.png)

You can then import the workbook to your instance of Kinetica using the plus icon on the workbooks tab.
![](/worbook_import.png)


### Other languages

Kinetica provides [APIs](https://docs.kinetica.com/7.1/api/) across different languages (Python, JavaScript, Java etc.) that can be used to connect to and query a Kinetica database server using a third party client.

# Install Kinetica
The easiest way to get started is with the free developer edition of Kinetica.

### [Install the free developer edition](https://www.kinetica.com/try/)
Kinetica offers a free developer edition that can be installed on Windows or Mac/Linux operating systems. Dev edition of Kinetica requires Docker with at least 8GB of RAM allocated. You can follow the instructions [here](https://www.kinetica.com/try/) to download and install the developer edition.

### [Launch Kinetica as a service on the cloud](https://www.kinetica.com/platform/cloud/)
There are free versions of Kinetica that can be provisioned as a managed service on Azure or AWS. You will have to pay a small fee for cloud infrastructure (to the cloud provider). Follow the instructions [here to provision Kinetica](https://www.kinetica.com/platform/cloud/) on the cloud.


### Install the on-premise version of Kinetica
You can also deploy an on-premise version of Kinetica. You can find more information on the different installation options [here](https://docs.kinetica.com/7.1/install/installation-options/). 

# Support
If you found a bug please submit an [issue on Github](https://github.com/kineticadb/examples/issues). Please reference the example that you are having an issue with in the title.

To get community support, you can: 
1. Ask a question in our [community slack channel](https://join.slack.com/t/kinetica-community/shared_invite/zt-1bt9x3mvr-uMKrXlSDXfy3oU~sKi84qg) 
2. Post on [stackoverflow](https://stackoverflow.com/questions/tagged/kinetica) under the kinetica tag.

## More Information
See our [Documentation](http://docs.kinetica.com/7.1/azure) for more information about workbooks and the Kinetica workbench.
