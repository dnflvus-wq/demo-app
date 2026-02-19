import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { Save, X } from 'lucide-react';
import type { Post, ToastType } from '../../types';
import { getPosts, savePosts, generateId, formatDate } from '../../utils/storage';

interface Props {
  addToast: (type: ToastType, message: string) => void;
}

export default function BoardWritePage({ addToast }: Props) {
  const navigate = useNavigate();
  const { id } = useParams<{ id: string }>();
  const isEdit = !!id;

  const [title, setTitle] = useState('');
  const [author, setAuthor] = useState('');
  const [content, setContent] = useState('');
  const [category, setCategory] = useState<Post['category']>('free');
  const [secret, setSecret] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    if (isEdit) {
      const posts = getPosts();
      const post = posts.find((p) => p.id === id);
      if (post) {
        setTitle(post.title);
        setAuthor(post.author);
        setContent(post.content);
        setCategory(post.category);
        setSecret(post.secret);
      } else {
        navigate('/board');
      }
    }
  }, [id, isEdit, navigate]);

  const validate = (): boolean => {
    const errs: Record<string, string> = {};
    if (!title.trim()) errs.title = '제목을 입력해주세요';
    if (!author.trim()) errs.author = '작성자를 입력해주세요';
    if (!content.trim()) errs.content = '내용을 입력해주세요';
    else if (content.trim().length < 10) errs.content = '내용을 10자 이상 입력해주세요';
    setErrors(errs);
    return Object.keys(errs).length === 0;
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!validate()) return;

    const posts = getPosts();

    if (isEdit) {
      const updated = posts.map((p) =>
        p.id === id
          ? { ...p, title: title.trim(), author: author.trim(), content: content.trim(), category, secret }
          : p
      );
      savePosts(updated);
      addToast('success', '글이 수정되었습니다');
      navigate(`/board/${id}`);
    } else {
      const newPost: Post = {
        id: generateId(),
        title: title.trim(),
        author: author.trim(),
        content: content.trim(),
        category,
        secret,
        views: 0,
        createdAt: formatDate(new Date()),
      };
      savePosts([...posts, newPost]);
      addToast('success', '글이 등록되었습니다');
      navigate('/board');
    }
  };

  const clearError = (field: string) => {
    setErrors((prev) => {
      const next = { ...prev };
      delete next[field];
      return next;
    });
  };

  return (
    <div data-testid="board-write-page">
      <h1 className="text-2xl font-bold text-gray-800 mb-6">{isEdit ? '글 수정' : '글 작성'}</h1>

      <form onSubmit={handleSubmit} className="bg-white rounded-xl border border-gray-200 p-6" data-testid="post-form">
        <div className="flex flex-col gap-4">
          {/* Title */}
          <div>
            <label htmlFor="post-title" className="block text-sm font-medium text-gray-700 mb-1">
              제목 <span className="text-red-500">*</span>
            </label>
            <input
              id="post-title"
              name="post-title"
              type="text"
              value={title}
              onChange={(e) => { setTitle(e.target.value); clearError('title'); }}
              maxLength={100}
              placeholder="제목을 입력하세요"
              className={`w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 ${
                errors.title ? 'border-red-400' : 'border-gray-300'
              }`}
              data-testid="post-title"
            />
            {errors.title && <p className="text-red-500 text-xs mt-1" data-testid="error-title">{errors.title}</p>}
          </div>

          {/* Author */}
          <div>
            <label htmlFor="post-author" className="block text-sm font-medium text-gray-700 mb-1">
              작성자 <span className="text-red-500">*</span>
            </label>
            <input
              id="post-author"
              name="post-author"
              type="text"
              value={author}
              onChange={(e) => { setAuthor(e.target.value); clearError('author'); }}
              placeholder="작성자명을 입력하세요"
              className={`w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 ${
                errors.author ? 'border-red-400' : 'border-gray-300'
              }`}
              data-testid="post-author"
            />
            {errors.author && <p className="text-red-500 text-xs mt-1" data-testid="error-author">{errors.author}</p>}
          </div>

          {/* Category + Secret */}
          <div className="flex gap-4 items-end">
            <div className="flex-1">
              <label htmlFor="post-category" className="block text-sm font-medium text-gray-700 mb-1">카테고리</label>
              <select
                id="post-category"
                name="post-category"
                value={category}
                onChange={(e) => setCategory(e.target.value as Post['category'])}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                data-testid="post-category"
              >
                <option value="notice">공지</option>
                <option value="free">자유</option>
                <option value="question">질문</option>
              </select>
            </div>
            <label className="flex items-center gap-2 pb-2 cursor-pointer">
              <input
                type="checkbox"
                checked={secret}
                onChange={(e) => setSecret(e.target.checked)}
                className="w-4 h-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                data-testid="post-secret"
              />
              <span className="text-sm text-gray-600">비밀글</span>
            </label>
          </div>

          {/* Content */}
          <div>
            <label htmlFor="post-content" className="block text-sm font-medium text-gray-700 mb-1">
              내용 <span className="text-red-500">*</span>
            </label>
            <textarea
              id="post-content"
              name="post-content"
              value={content}
              onChange={(e) => { setContent(e.target.value); clearError('content'); }}
              placeholder="내용을 입력하세요 (최소 10자)"
              rows={8}
              className={`w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none ${
                errors.content ? 'border-red-400' : 'border-gray-300'
              }`}
              data-testid="post-content"
            />
            {errors.content && <p className="text-red-500 text-xs mt-1" data-testid="error-content">{errors.content}</p>}
            <p className="text-xs text-gray-400 mt-1 text-right">{content.length}자</p>
          </div>

          {/* Buttons */}
          <div className="flex justify-end gap-3 pt-2">
            <button
              type="button"
              onClick={() => navigate(-1)}
              className="flex items-center gap-1.5 px-4 py-2 text-sm rounded-lg border border-gray-300 text-gray-600 hover:bg-gray-50"
              data-testid="post-cancel-btn"
            >
              <X className="w-4 h-4" />
              취소
            </button>
            <button
              type="submit"
              className="flex items-center gap-1.5 px-4 py-2 text-sm rounded-lg bg-blue-600 text-white hover:bg-blue-700"
              data-testid="post-save-btn"
            >
              <Save className="w-4 h-4" />
              {isEdit ? '수정' : '등록'}
            </button>
          </div>
        </div>
      </form>
    </div>
  );
}
