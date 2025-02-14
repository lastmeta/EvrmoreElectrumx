import { AppModule } from './app.module';
import { SocketService } from './socket/socket.service';
import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule, {
    logger: ['log', 'error', 'warn', 'debug', 'verbose']
  });

  // Get the SocketService instance
  const socketService = app.get(SocketService);

  // Connect to your WebSocket server
  // socketService.connect('ws://localhost:8080');
  socketService.connect('ws://192.168.29.34:8080');

  await app.listen(3000);
  // Send a message to the WebSocket server EVERY 10 SECONDS

  setInterval(() => {
    socketService.send({
      func: 'getWallets', "data": {
        "filters": {
          "chain": "evrmore",
          "filterType": "nonzero",
          "symbol": "satori"
        }
      }
    });
  }, 60000 * 5);
}

bootstrap();
