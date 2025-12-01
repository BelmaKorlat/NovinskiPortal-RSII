using System;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Options;
using NovinskiPortal.Common.Messaging;
using NovinskiPortal.Common.Settings;
using RabbitMQ.Client;

namespace NovinskiPortal.Services.Messaging
{
    public class RabbitMqEventPublisher : IEventPublisher, IDisposable
    {
        private readonly RabbitMqSettings _settings;

        private readonly ConnectionFactory _factory;
        private IConnection? _connection;
        private IChannel? _channel;

        // da spriječiš da se više threadova istovremeno inicijalizuje channel
        private readonly SemaphoreSlim _initLock = new(1, 1);

        public RabbitMqEventPublisher(IOptions<RabbitMqSettings> options)
        {
            _settings = options.Value;

            _factory = new ConnectionFactory
            {
                HostName = _settings.HostName,
                Port = _settings.Port,
                UserName = _settings.UserName,
                Password = _settings.Password,
                ClientProvidedName = "novinskiportal-publisher"
            };
        }

        // Lazy async init konekcije i kanala
        private async Task<IChannel> GetOrCreateChannelAsync()
        {
            if (_channel != null && _channel.IsOpen)
            {
                return _channel;
            }

            await _initLock.WaitAsync();
            try
            {
                // provjeri opet, možda je neko drugi već napravio channel
                if (_channel != null && _channel.IsOpen)
                {
                    return _channel;
                }

                // ubij staru konekciju ako postoji
                _channel?.Dispose();
                _connection?.Dispose();

                _connection = await _factory.CreateConnectionAsync();
                _channel = await _connection.CreateChannelAsync();

                // kreiraj exchange ako ne postoji
                await _channel.ExchangeDeclareAsync(
                    exchange: _settings.Exchange,
                    type: ExchangeType.Topic,
                    durable: true,
                    autoDelete: false,
                    arguments: null);

                return _channel;
            }
            finally
            {
                _initLock.Release();
            }
        }

        public async Task PublishArticleViewedAsync(ArticleViewedEvent @event)
        {
            var channel = await GetOrCreateChannelAsync();

            var json = JsonSerializer.Serialize(@event);
            var body = Encoding.UTF8.GetBytes(json);

            // u v7 BasicPublishAsync je generic, koristi BasicProperties
            var props = new BasicProperties();

            await channel.BasicPublishAsync(
                exchange: _settings.Exchange,
                routingKey: _settings.RoutingKeyArticleViewed,
                mandatory: false,
                basicProperties: props,
                body: body,
                cancellationToken: CancellationToken.None);
        }

        public void Dispose()
        {
            _channel?.Dispose();
            _connection?.Dispose();
            _initLock.Dispose();
        }
    }
}
