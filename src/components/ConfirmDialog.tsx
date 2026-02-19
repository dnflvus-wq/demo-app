interface Props {
  open: boolean;
  message: string;
  onConfirm: () => void;
  onCancel: () => void;
}

export default function ConfirmDialog({ open, message, onConfirm, onCancel }: Props) {
  if (!open) return null;

  return (
    <div className="fixed inset-0 z-40 flex items-center justify-center bg-black/40" data-testid="confirm-dialog">
      <div className="bg-white rounded-xl shadow-xl p-6 w-[360px]">
        <p className="text-gray-800 text-base mb-6" data-testid="confirm-message">{message}</p>
        <div className="flex justify-end gap-3">
          <button
            onClick={onCancel}
            className="px-4 py-2 text-sm rounded-lg border border-gray-300 text-gray-600 hover:bg-gray-50"
            data-testid="confirm-cancel"
          >
            취소
          </button>
          <button
            onClick={onConfirm}
            className="px-4 py-2 text-sm rounded-lg bg-red-500 text-white hover:bg-red-600"
            data-testid="confirm-ok"
          >
            확인
          </button>
        </div>
      </div>
    </div>
  );
}
