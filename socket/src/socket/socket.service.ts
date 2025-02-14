import { Injectable } from '@nestjs/common';
import { WebSocket } from 'ws';

@Injectable()
export class SocketService {
  private ws: WebSocket;

  constructor() { }

  public connect(url: string) {
    this.ws = new WebSocket(url);

    this.ws.on('open', () => {
      console.log('Connected to WebSocket server');
    });

    this.ws.on('message', (message: string) => {
      this.handleMessage(message);
    });

    this.ws.on('close', () => {
      console.log('Disconnected from WebSocket server');
    });

    this.ws.on('error', (error) => {
      console.error('WebSocket error details:', {
        message: error.message,
        type: error.type,
        target: error.target,
        // Log the full error object to see all available information
        fullError: JSON.stringify(error, Object.getOwnPropertyNames(error))
      });
      
      // Try to reconnect after a delay
      setTimeout(() => {
        console.log('Attempting to reconnect...');
        this.connect(url);
      }, 5000); // Retry every 5 seconds
    
    });
  }

  private handleMessage(message: string): void {
    try {
      const parsedMessage = JSON.parse(message);
      console.log('Received message:', JSON.stringify(parsedMessage, null, 2));
    } catch (error) {
      console.error('Error parsing message:', error);
    }
  }

  public send(message: any): void {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify(message));
    } else {
      console.error('WebSocket is not connected');
    }
  }
}
