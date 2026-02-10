#include "synchttpclient.h"

SyncHttpClient::SyncHttpClient(int timeoutMs)
    : m_timeoutMs(timeoutMs)
{
}

HttpClient::HttpResponse SyncHttpClient::get(const QUrl& url)
{
  return waitForResult([&](HttpClient& client) { client.get(url); });
}

HttpClient::HttpResponse SyncHttpClient::postJson(const QUrl& url, const QJsonObject& json)
{
  return waitForResult([&](HttpClient& client) { client.postJson(url, json); });
}

HttpClient::HttpResponse SyncHttpClient::postFile(const QUrl& url, const QString& filePath)
{
  return waitForResult([&](HttpClient& client) { client.postFile(url, filePath); });
}

HttpClient::HttpResponse SyncHttpClient::waitForResult(std::function<void(HttpClient&)> requestFunc)
{
  QEventLoop loop;
  QTimer timer;
  timer.setSingleShot(true);

  HttpClient* client = new HttpClient();
  HttpClient::HttpResponse result;

  QObject::connect(client, &HttpClient::finished, [&](const HttpClient::HttpResponse& response) {
    result = response;
    loop.quit();
    client->deleteLater();
  });

  QObject::connect(&timer, &QTimer::timeout, [&]() {
    result.success = false;
    result.errorMessage = "Request timeout";
    loop.quit();
  });

  timer.start(m_timeoutMs);

  requestFunc(*client);
  loop.exec();

  return result;
}
