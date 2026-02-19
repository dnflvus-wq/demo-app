import { useEffect } from 'react';
import { CheckCircle, XCircle, Info, X } from 'lucide-react';
import type { ToastMessage } from '../types';

interface Props {
  toasts: ToastMessage[];
  onRemove: (id: string) => void;
}

const icons = {
  success: <CheckCircle className="w-5 h-5 text-green-500" />,
  error: <XCircle className="w-5 h-5 text-red-500" />,
  info: <Info className="w-5 h-5 text-blue-500" />,
};

const bgColors = {
  success: 'bg-green-50 border-green-200',
  error: 'bg-red-50 border-red-200',
  info: 'bg-blue-50 border-blue-200',
};

export default function Toast({ toasts, onRemove }: Props) {
  return (
    <div className="fixed top-4 right-4 z-50 flex flex-col gap-2" data-testid="toast-container">
      {toasts.map((t) => (
        <ToastItem key={t.id} toast={t} onRemove={onRemove} />
      ))}
    </div>
  );
}

function ToastItem({ toast, onRemove }: { toast: ToastMessage; onRemove: (id: string) => void }) {
  useEffect(() => {
    const timer = setTimeout(() => onRemove(toast.id), 3000);
    return () => clearTimeout(timer);
  }, [toast.id, onRemove]);

  return (
    <div
      className={`flex items-center gap-2 px-4 py-3 rounded-lg border shadow-md min-w-[280px] ${bgColors[toast.type]}`}
      data-testid="toast-message"
    >
      {icons[toast.type]}
      <span className="flex-1 text-sm">{toast.message}</span>
      <button onClick={() => onRemove(toast.id)} className="text-gray-400 hover:text-gray-600" data-testid="toast-close">
        <X className="w-4 h-4" />
      </button>
    </div>
  );
}
