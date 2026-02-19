import { useState, useMemo } from 'react';
import { Plus, Pencil, Trash2, Search } from 'lucide-react';
import type { Todo, ToastType } from '../../types';
import { getTodos, saveTodos, generateId, formatDate } from '../../utils/storage';
import ConfirmDialog from '../../components/ConfirmDialog';

type Filter = 'all' | 'active' | 'completed';

interface Props {
  addToast: (type: ToastType, message: string) => void;
}

export default function TodoPage({ addToast }: Props) {
  const [todos, setTodos] = useState<Todo[]>(getTodos);
  const [title, setTitle] = useState('');
  const [desc, setDesc] = useState('');
  const [priority, setPriority] = useState<Todo['priority']>('medium');
  const [filter, setFilter] = useState<Filter>('all');
  const [search, setSearch] = useState('');
  const [error, setError] = useState('');
  const [editingId, setEditingId] = useState<string | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<string | null>(null);

  const persist = (updated: Todo[]) => {
    setTodos(updated);
    saveTodos(updated);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim()) {
      setError('제목을 입력해주세요');
      return;
    }
    setError('');

    if (editingId) {
      const updated = todos.map((t) =>
        t.id === editingId ? { ...t, title: title.trim(), description: desc.trim(), priority } : t
      );
      persist(updated);
      addToast('success', 'Todo가 수정되었습니다');
      setEditingId(null);
    } else {
      const newTodo: Todo = {
        id: generateId(),
        title: title.trim(),
        description: desc.trim(),
        priority,
        completed: false,
        createdAt: formatDate(new Date()),
      };
      persist([...todos, newTodo]);
      addToast('success', 'Todo가 추가되었습니다');
    }
    setTitle('');
    setDesc('');
    setPriority('medium');
  };

  const handleEdit = (todo: Todo) => {
    setEditingId(todo.id);
    setTitle(todo.title);
    setDesc(todo.description);
    setPriority(todo.priority);
    setError('');
  };

  const handleCancelEdit = () => {
    setEditingId(null);
    setTitle('');
    setDesc('');
    setPriority('medium');
    setError('');
  };

  const handleToggle = (id: string) => {
    const updated = todos.map((t) => (t.id === id ? { ...t, completed: !t.completed } : t));
    persist(updated);
  };

  const handleDelete = () => {
    if (!deleteTarget) return;
    persist(todos.filter((t) => t.id !== deleteTarget));
    setDeleteTarget(null);
    addToast('info', 'Todo가 삭제되었습니다');
  };

  const filtered = useMemo(() => {
    let result = todos;
    if (filter === 'active') result = result.filter((t) => !t.completed);
    if (filter === 'completed') result = result.filter((t) => t.completed);
    if (search.trim()) {
      const q = search.trim().toLowerCase();
      result = result.filter((t) => t.title.toLowerCase().includes(q));
    }
    return result;
  }, [todos, filter, search]);

  const priorityLabel = { high: '높음', medium: '보통', low: '낮음' };
  const priorityColor = { high: 'text-red-500', medium: 'text-yellow-500', low: 'text-gray-400' };

  return (
    <div data-testid="todo-page">
      <h1 className="text-2xl font-bold text-gray-800 mb-6">Todo 관리</h1>

      {/* Add / Edit Form */}
      <form onSubmit={handleSubmit} className="bg-white rounded-xl border border-gray-200 p-5 mb-6" data-testid="todo-form">
        <div className="flex flex-col gap-3">
          <div>
            <label htmlFor="todo-title" className="block text-sm font-medium text-gray-700 mb-1">
              제목 <span className="text-red-500">*</span>
            </label>
            <input
              id="todo-title"
              name="todo-title"
              type="text"
              value={title}
              onChange={(e) => { setTitle(e.target.value); setError(''); }}
              maxLength={50}
              placeholder="할 일을 입력하세요"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              data-testid="todo-title"
            />
            {error && <p className="text-red-500 text-xs mt-1" data-testid="error-title">{error}</p>}
          </div>
          <div>
            <label htmlFor="todo-desc" className="block text-sm font-medium text-gray-700 mb-1">설명</label>
            <textarea
              id="todo-desc"
              name="todo-desc"
              value={desc}
              onChange={(e) => setDesc(e.target.value)}
              placeholder="설명 (선택사항)"
              rows={2}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
              data-testid="todo-desc"
            />
          </div>
          <div className="flex items-end gap-3">
            <div className="flex-1">
              <label htmlFor="todo-priority" className="block text-sm font-medium text-gray-700 mb-1">우선순위</label>
              <select
                id="todo-priority"
                name="todo-priority"
                value={priority}
                onChange={(e) => setPriority(e.target.value as Todo['priority'])}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                data-testid="todo-priority"
              >
                <option value="high">높음</option>
                <option value="medium">보통</option>
                <option value="low">낮음</option>
              </select>
            </div>
            <div className="flex gap-2">
              {editingId && (
                <button
                  type="button"
                  onClick={handleCancelEdit}
                  className="px-4 py-2 text-sm rounded-lg border border-gray-300 text-gray-600 hover:bg-gray-50"
                  data-testid="todo-cancel-btn"
                >
                  취소
                </button>
              )}
              <button
                type="submit"
                className="flex items-center gap-1.5 px-4 py-2 text-sm rounded-lg bg-blue-600 text-white hover:bg-blue-700"
                data-testid="todo-add-btn"
              >
                <Plus className="w-4 h-4" />
                {editingId ? '수정' : '추가'}
              </button>
            </div>
          </div>
        </div>
      </form>

      {/* Filter + Search */}
      <div className="flex items-center gap-4 mb-4">
        <div className="flex gap-1 bg-gray-100 rounded-lg p-1">
          {(['all', 'active', 'completed'] as Filter[]).map((f) => (
            <button
              key={f}
              onClick={() => setFilter(f)}
              className={`px-3 py-1.5 text-sm rounded-md font-medium transition-colors ${
                filter === f ? 'bg-white text-blue-600 shadow-sm' : 'text-gray-500 hover:text-gray-700'
              }`}
              data-testid={`filter-${f}`}
            >
              {f === 'all' ? '전체' : f === 'active' ? '진행중' : '완료'}
            </button>
          ))}
        </div>
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="검색..."
            className="w-full pl-9 pr-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
            data-testid="todo-search"
          />
        </div>
      </div>

      {/* Todo List */}
      <div className="bg-white rounded-xl border border-gray-200 divide-y divide-gray-100">
        {filtered.length === 0 ? (
          <div className="p-8 text-center text-gray-400 text-sm" data-testid="todo-empty">
            {search ? '검색 결과가 없습니다' : 'Todo가 없습니다. 새로운 할 일을 추가해보세요!'}
          </div>
        ) : (
          filtered.map((todo) => (
            <div
              key={todo.id}
              className={`flex items-center gap-3 px-5 py-4 ${todo.completed ? 'bg-gray-50' : ''}`}
              data-testid={`todo-item-${todo.id}`}
            >
              <input
                type="checkbox"
                checked={todo.completed}
                onChange={() => handleToggle(todo.id)}
                className="w-5 h-5 rounded border-gray-300 text-blue-600 focus:ring-blue-500 cursor-pointer"
                data-testid={`todo-check-${todo.id}`}
              />
              <div className="flex-1 min-w-0">
                <div className={`text-sm font-medium ${todo.completed ? 'line-through text-gray-400' : 'text-gray-800'}`}>
                  {todo.title}
                </div>
                {todo.description && (
                  <div className="text-xs text-gray-400 mt-0.5 truncate">{todo.description}</div>
                )}
              </div>
              <span className={`text-xs font-medium ${priorityColor[todo.priority]}`} data-testid={`todo-priority-${todo.id}`}>
                {priorityLabel[todo.priority]}
              </span>
              <span className="text-xs text-gray-400">{todo.createdAt}</span>
              <button
                onClick={() => handleEdit(todo)}
                className="p-1.5 text-gray-400 hover:text-blue-600 rounded-lg hover:bg-blue-50"
                data-testid={`todo-edit-${todo.id}`}
                title="수정"
              >
                <Pencil className="w-4 h-4" />
              </button>
              <button
                onClick={() => setDeleteTarget(todo.id)}
                className="p-1.5 text-gray-400 hover:text-red-500 rounded-lg hover:bg-red-50"
                data-testid={`todo-delete-${todo.id}`}
                title="삭제"
              >
                <Trash2 className="w-4 h-4" />
              </button>
            </div>
          ))
        )}
      </div>

      <ConfirmDialog
        open={deleteTarget !== null}
        message="정말 삭제하시겠습니까?"
        onConfirm={handleDelete}
        onCancel={() => setDeleteTarget(null)}
      />
    </div>
  );
}
