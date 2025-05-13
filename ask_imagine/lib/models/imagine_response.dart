// To parse this JSON data, do
//
//     final imagineResponse = imagineResponseFromJson(jsonString);

import 'dart:convert';

List<ImagineResponse> imagineResponseFromJson(String str) =>
    List<ImagineResponse>.from(
      json.decode(str).map((x) => ImagineResponse.fromJson(x)),
    );

String imagineResponseToJson(List<ImagineResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ImagineResponse {
  final Content? content;
  final String? invocationId;
  final String? author;
  final Actions? actions;
  final String? id;
  final double? timestamp;
  final List<dynamic>? longRunningToolIds;

  ImagineResponse({
    this.content,
    this.invocationId,
    this.author,
    this.actions,
    this.id,
    this.timestamp,
    this.longRunningToolIds,
  });

  factory ImagineResponse.fromJson(
    Map<String, dynamic> json,
  ) => ImagineResponse(
    content: json["content"] == null ? null : Content.fromJson(json["content"]),
    invocationId: json["invocation_id"],
    author: json["author"],
    actions: json["actions"] == null ? null : Actions.fromJson(json["actions"]),
    id: json["id"],
    timestamp: json["timestamp"]?.toDouble(),
    longRunningToolIds:
        json["long_running_tool_ids"] == null
            ? []
            : List<dynamic>.from(json["long_running_tool_ids"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "content": content?.toJson(),
    "invocation_id": invocationId,
    "author": author,
    "actions": actions?.toJson(),
    "id": id,
    "timestamp": timestamp,
    "long_running_tool_ids":
        longRunningToolIds == null
            ? []
            : List<dynamic>.from(longRunningToolIds!.map((x) => x)),
  };
}

class Actions {
  final StateDelta? stateDelta;
  final ArtifactDelta? artifactDelta;
  final ArtifactDelta? requestedAuthConfigs;

  Actions({this.stateDelta, this.artifactDelta, this.requestedAuthConfigs});

  factory Actions.fromJson(Map<String, dynamic> json) => Actions(
    stateDelta:
        json["state_delta"] == null
            ? null
            : StateDelta.fromJson(json["state_delta"]),
    artifactDelta:
        json["artifact_delta"] == null
            ? null
            : ArtifactDelta.fromJson(json["artifact_delta"]),
    requestedAuthConfigs:
        json["requested_auth_configs"] == null
            ? null
            : ArtifactDelta.fromJson(json["requested_auth_configs"]),
  );

  Map<String, dynamic> toJson() => {
    "state_delta": stateDelta?.toJson(),
    "artifact_delta": artifactDelta?.toJson(),
    "requested_auth_configs": requestedAuthConfigs?.toJson(),
  };
}

class ArtifactDelta {
  ArtifactDelta();

  factory ArtifactDelta.fromJson(Map<String, dynamic> json) => ArtifactDelta();

  Map<String, dynamic> toJson() => {};
}

class StateDelta {
  final String? detailedPrompt;

  StateDelta({this.detailedPrompt});

  factory StateDelta.fromJson(Map<String, dynamic> json) =>
      StateDelta(detailedPrompt: json["detailed_prompt"]);

  Map<String, dynamic> toJson() => {"detailed_prompt": detailedPrompt};
}

class Content {
  final List<Part>? parts;
  final String? role;

  Content({this.parts, this.role});

  factory Content.fromJson(Map<String, dynamic> json) => Content(
    parts:
        json["parts"] == null
            ? []
            : List<Part>.from(json["parts"]!.map((x) => Part.fromJson(x))),
    role: json["role"],
  );

  Map<String, dynamic> toJson() => {
    "parts":
        parts == null ? [] : List<dynamic>.from(parts!.map((x) => x.toJson())),
    "role": role,
  };
}

class Part {
  final String? text;
  final FunctionCall? functionCall;
  final FunctionResponse? functionResponse;

  Part({this.text, this.functionCall, this.functionResponse});

  factory Part.fromJson(Map<String, dynamic> json) => Part(
    text: json["text"],
    functionCall:
        json["functionCall"] == null
            ? null
            : FunctionCall.fromJson(json["functionCall"]),
    functionResponse:
        json["functionResponse"] == null
            ? null
            : FunctionResponse.fromJson(json["functionResponse"]),
  );

  Map<String, dynamic> toJson() => {
    "text": text,
    "functionCall": functionCall?.toJson(),
    "functionResponse": functionResponse?.toJson(),
  };
}

class FunctionCall {
  final String? id;
  final StateDelta? args;
  final String? name;

  FunctionCall({this.id, this.args, this.name});

  factory FunctionCall.fromJson(Map<String, dynamic> json) => FunctionCall(
    id: json["id"],
    args: json["args"] == null ? null : StateDelta.fromJson(json["args"]),
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "args": args?.toJson(),
    "name": name,
  };
}

class FunctionResponse {
  final String? id;
  final String? name;
  final Response? response;

  FunctionResponse({this.id, this.name, this.response});

  factory FunctionResponse.fromJson(Map<String, dynamic> json) =>
      FunctionResponse(
        id: json["id"],
        name: json["name"],
        response:
            json["response"] == null
                ? null
                : Response.fromJson(json["response"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "response": response?.toJson(),
  };
}

class Response {
  final String? result;

  Response({this.result});

  factory Response.fromJson(Map<String, dynamic> json) =>
      Response(result: json["result"]);

  Map<String, dynamic> toJson() => {"result": result};
}
