package me.chanjar.docker;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.text.StringEscapeUtils;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.EnvironmentAware;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
public class EnvironmentPrinter implements CommandLineRunner, EnvironmentAware {


  @Override
  public void run(String... args) throws Exception {

    System.out.println("============== ARGUMENTS ==============");
    if (args != null && args.length > 0) {
      for (String arg : args) {
        System.out.println(arg);
      }
    }

  }

  @Override
  public void setEnvironment(Environment environment) {

    ConfigurableEnvironment configEnv = (ConfigurableEnvironment) environment;

    System.out.println("============== SYSTEM PROPERTIES ==============");
    printMap(configEnv.getSystemProperties());

    System.out.println();

    System.out.println("============== SYSTEM ENVIRONMENTS ==============");
    printMap(configEnv.getSystemEnvironment());

  }

  private void printMap(Map<String, Object> map) {

    int paddingLength = 30;
    for (Map.Entry<String, Object> entry : map.entrySet()) {

      System.out.println(StringEscapeUtils.escapeJava(StringUtils.rightPad(entry.getKey(), paddingLength))
          + ": "
          + StringEscapeUtils.escapeJava(entry.getValue().toString()));
    }

  }

}
