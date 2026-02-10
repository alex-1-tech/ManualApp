#pragma once

#include <QEventLoop>
#include <QTimer>

#include "httpclient.h"

class SyncHttpClient
{
public:
  explicit SyncHttpClient(int timeoutMs = 30000);

  HttpClient::HttpResponse get(const QUrl& url);
  HttpClient::HttpResponse postJson(const QUrl& url, const QJsonObject& json);
  HttpClient::HttpResponse postFile(const QUrl& url, const QString& filePath);

private:
  HttpClient::HttpResponse waitForResult(std::function<void(HttpClient&)> requestFunc);

private:
  int m_timeoutMs;
};
