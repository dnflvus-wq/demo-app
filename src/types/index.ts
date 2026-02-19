export interface Todo {
  id: string;
  title: string;
  description: string;
  priority: 'high' | 'medium' | 'low';
  completed: boolean;
  createdAt: string;
}

export interface Post {
  id: string;
  title: string;
  author: string;
  content: string;
  category: 'notice' | 'free' | 'question';
  secret: boolean;
  views: number;
  createdAt: string;
}

export type ToastType = 'success' | 'error' | 'info';

export interface ToastMessage {
  id: string;
  type: ToastType;
  message: string;
}
