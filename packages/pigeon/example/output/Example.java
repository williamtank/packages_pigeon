// Autogenerated from Pigeon (v0.1.21), do not edit directly.
// See also: https://pub.dev/packages/pigeon

package com.bytedance.artist.example;

import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import java.util.ArrayList;
import java.util.HashMap;

/** Generated class from Pigeon. */
@SuppressWarnings("unused")
public class Example {

  /** Generated class from Pigeon that represents data sent in messages. */
  public static class Reply {
    private String result;
    public String getResult() { return result; }
    public void setResult(String setterArg) { this.result = setterArg; }

    private ArrayList list;
    public ArrayList getList() { return list; }
    public void setList(ArrayList setterArg) { this.list = setterArg; }

    HashMap toMap() {
      HashMap<String, Object> toMapResult = new HashMap<>();
      toMapResult.put("result", result);
      toMapResult.put("list", list);
      return toMapResult;
    }
    static Reply fromMap(HashMap map) {
      Reply fromMapResult = new Reply();
      Object result = map.get("result");
      fromMapResult.result = (String)result;
      Object list = map.get("list");
      fromMapResult.list = (ArrayList)list;
      return fromMapResult;
    }
  }

  /** Generated class from Pigeon that represents data sent in messages. */
  public static class Request {
    private String query;
    public String getQuery() { return query; }
    public void setQuery(String setterArg) { this.query = setterArg; }

    HashMap toMap() {
      HashMap<String, Object> toMapResult = new HashMap<>();
      toMapResult.put("query", query);
      return toMapResult;
    }
    static Request fromMap(HashMap map) {
      Request fromMapResult = new Request();
      Object query = map.get("query");
      fromMapResult.query = (String)query;
      return fromMapResult;
    }
  }

  /** Generated class from Pigeon that represents data sent in messages. */
  public static class Person {
    private String name;
    public String getName() { return name; }
    public void setName(String setterArg) { this.name = setterArg; }

    private Long age;
    public Long getAge() { return age; }
    public void setAge(Long setterArg) { this.age = setterArg; }

    HashMap toMap() {
      HashMap<String, Object> toMapResult = new HashMap<>();
      toMapResult.put("name", name);
      toMapResult.put("age", age);
      return toMapResult;
    }
    static Person fromMap(HashMap map) {
      Person fromMapResult = new Person();
      Object name = map.get("name");
      fromMapResult.name = (String)name;
      Object age = map.get("age");
      fromMapResult.age = (age == null) ? null : ((age instanceof Integer) ? (Integer)age : (Long)age);
      return fromMapResult;
    }
  }

  public interface Result<T> {
    void success(T result);
  }

  /** Generated interface from Pigeon that represents a handler of messages from Flutter.*/
  public interface ExampleApi {
    Void searchVoid();
    String searchArgEmpty();
    Void searchReturnEmpty();
    Reply search(Request request);
    boolean searchMore(int code, Person person);
    void searchMoreAsync(String name, boolean needFullName, Result<String> result);
    void searchReturnAsync(int code, Person person, Result<Void> result);
    void searchEmptyAsync(Result<Reply> result);

    /** Sets up an instance of `ExampleApi` to handle messages through the `binaryMessenger` */
    static void setup(BinaryMessenger binaryMessenger, ExampleApi api) {
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(binaryMessenger, "dev.flutter.pigeon.ExampleApi.searchVoid", new StandardMessageCodec());
        if (api != null) {
          channel.setMessageHandler((message, reply) -> {
            HashMap<String, Object> wrapped = new HashMap<>();
            try {
              api.searchVoid();
              wrapped.put("result", null);
            }
            catch (Exception exception) {
              wrapped.put("error", wrapError(exception));
            }
            reply.reply(wrapped);
          });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(binaryMessenger, "dev.flutter.pigeon.ExampleApi.searchArgEmpty", new StandardMessageCodec());
        if (api != null) {
          channel.setMessageHandler((message, reply) -> {
            HashMap<String, Object> wrapped = new HashMap<>();
            try {
              String output = api.searchArgEmpty();
              wrapped.put("result", output);
            }
            catch (Exception exception) {
              wrapped.put("error", wrapError(exception));
            }
            reply.reply(wrapped);
          });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(binaryMessenger, "dev.flutter.pigeon.ExampleApi.searchReturnEmpty", new StandardMessageCodec());
        if (api != null) {
          channel.setMessageHandler((message, reply) -> {
            HashMap<String, Object> wrapped = new HashMap<>();
            try {
              api.searchReturnEmpty();
              wrapped.put("result", null);
            }
            catch (Exception exception) {
              wrapped.put("error", wrapError(exception));
            }
            reply.reply(wrapped);
          });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(binaryMessenger, "dev.flutter.pigeon.ExampleApi.search", new StandardMessageCodec());
        if (api != null) {
          channel.setMessageHandler((message, reply) -> {
            HashMap<String, Object> wrapped = new HashMap<>();
            try {
              @SuppressWarnings("ConstantConditions")
              HashMap reqParams = (HashMap) message;
              Request request = Request.fromMap((HashMap) reqParams.get("request"));
              Reply output = api.search(request);
              wrapped.put("result", output.toMap());
            }
            catch (Exception exception) {
              wrapped.put("error", wrapError(exception));
            }
            reply.reply(wrapped);
          });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(binaryMessenger, "dev.flutter.pigeon.ExampleApi.searchMore", new StandardMessageCodec());
        if (api != null) {
          channel.setMessageHandler((message, reply) -> {
            HashMap<String, Object> wrapped = new HashMap<>();
            try {
              @SuppressWarnings("ConstantConditions")
              HashMap reqParams = (HashMap) message;
              int code = (int) reqParams.get("code");
              Person person = Person.fromMap((HashMap) reqParams.get("person"));
              boolean output = api.searchMore(code, person);
              wrapped.put("result", output);
            }
            catch (Exception exception) {
              wrapped.put("error", wrapError(exception));
            }
            reply.reply(wrapped);
          });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(binaryMessenger, "dev.flutter.pigeon.ExampleApi.searchMoreAsync", new StandardMessageCodec());
        if (api != null) {
          channel.setMessageHandler((message, reply) -> {
            HashMap<String, Object> wrapped = new HashMap<>();
            try {
              @SuppressWarnings("ConstantConditions")
              HashMap reqParams = (HashMap) message;
              String name = (String) reqParams.get("name");
              boolean needFullName = (boolean) reqParams.get("needFullName");
              api.searchMoreAsync(name, needFullName, result -> { wrapped.put("result", result); reply.reply(wrapped); });
            }
            catch (Exception exception) {
              wrapped.put("error", wrapError(exception));
              reply.reply(wrapped);
            }
          });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(binaryMessenger, "dev.flutter.pigeon.ExampleApi.searchReturnAsync", new StandardMessageCodec());
        if (api != null) {
          channel.setMessageHandler((message, reply) -> {
            HashMap<String, Object> wrapped = new HashMap<>();
            try {
              @SuppressWarnings("ConstantConditions")
              HashMap reqParams = (HashMap) message;
              int code = (int) reqParams.get("code");
              Person person = Person.fromMap((HashMap) reqParams.get("person"));
              api.searchReturnAsync(code, person, result -> { wrapped.put("result", result.toMap()); reply.reply(wrapped); });
            }
            catch (Exception exception) {
              wrapped.put("error", wrapError(exception));
              reply.reply(wrapped);
            }
          });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(binaryMessenger, "dev.flutter.pigeon.ExampleApi.searchEmptyAsync", new StandardMessageCodec());
        if (api != null) {
          channel.setMessageHandler((message, reply) -> {
            HashMap<String, Object> wrapped = new HashMap<>();
            try {
              api.searchEmptyAsync(result -> { wrapped.put("result", result.toMap()); reply.reply(wrapped); });
            }
            catch (Exception exception) {
              wrapped.put("error", wrapError(exception));
              reply.reply(wrapped);
            }
          });
        } else {
          channel.setMessageHandler(null);
        }
      }
    }
  }
  private static HashMap wrapError(Exception exception) {
    HashMap<String, Object> errorMap = new HashMap<>();
    errorMap.put("message", exception.toString());
    errorMap.put("code", exception.getClass().getSimpleName());
    errorMap.put("details", null);
    return errorMap;
  }
}
