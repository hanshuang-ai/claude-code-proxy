该项目是一个tomcat项目，proxy文件夹即为tomcat的主目录，里面集成了一个jre，按道理可以直接执行start.bat即可运行
如果是mac系统，需要自行安装jdk并配置好环境变量，然后启动proxy/bin/startup.sh即可启动tomcat服务，tomcat端口默认为8888
使用时，如果使用的是智普的大模型API，只需要把.claude下的settings.json里面的ip修改成http://localhost:8888/proxy即可
如果是claude或其他的API，那么除了上述修改外，还需要把项目文件proxy\webapps\proxy\WEB-INF\classes\config.xml里面的target结点改下，改成代理的目标API地址即可
在控制台或者proxy/logs/run.log里可以看请求的全部信息