import { useState, useCallback } from 'react';
import { Routes, Route } from 'react-router-dom';
import Layout from './components/Layout';
import Toast from './components/Toast';
// Added version info for GitHub integration test
import HomePage from './pages/HomePage';
import TodoPage from './pages/todo/TodoPage';
import BoardListPage from './pages/board/BoardListPage';
import BoardWritePage from './pages/board/BoardWritePage';
import BoardDetailPage from './pages/board/BoardDetailPage';
import EmbedPage from './pages/EmbedPage';
import type { ToastMessage, ToastType } from './types';

export default function App() {
  const [toasts, setToasts] = useState<ToastMessage[]>([]);

  const addToast = useCallback((type: ToastType, message: string) => {
    const id = Date.now().toString(36);
    setToasts((prev) => [...prev, { id, type, message }]);
  }, []);

  const removeToast = useCallback((id: string) => {
    setToasts((prev) => prev.filter((t) => t.id !== id));
  }, []);

  return (
    <>
      <Toast toasts={toasts} onRemove={removeToast} />
      <Routes>
        <Route element={<Layout />}>
          <Route path="/" element={<HomePage />} />
          <Route path="/todo" element={<TodoPage addToast={addToast} />} />
          <Route path="/board" element={<BoardListPage />} />
          <Route path="/board/write" element={<BoardWritePage addToast={addToast} />} />
          <Route path="/board/write/:id" element={<BoardWritePage addToast={addToast} />} />
          <Route path="/board/:id" element={<BoardDetailPage addToast={addToast} />} />
          <Route path="/embed" element={<EmbedPage />} />
        </Route>
      </Routes>
    </>
  );
}
