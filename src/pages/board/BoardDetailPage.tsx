import { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { ArrowLeft, Pencil, Trash2, Lock } from 'lucide-react';
import type { Post, ToastType } from '../../types';
import { getPosts, savePosts } from '../../utils/storage';
import ConfirmDialog from '../../components/ConfirmDialog';

const categoryLabel: Record<string, string> = { notice: '공지', free: '자유', question: '질문' };

interface Props {
  addToast: (type: ToastType, message: string) => void;
}

export default function BoardDetailPage({ addToast }: Props) {
  const navigate = useNavigate();
  const { id } = useParams<{ id: string }>();
  const [post, setPost] = useState<Post | null>(null);
  const [showDelete, setShowDelete] = useState(false);

  useEffect(() => {
    const posts = getPosts();
    const found = posts.find((p) => p.id === id);
    if (found) {
      // increment views
      const updated = posts.map((p) => (p.id === id ? { ...p, views: p.views + 1 } : p));
      savePosts(updated);
      setPost({ ...found, views: found.views + 1 });
    } else {
      navigate('/board');
    }
  }, [id, navigate]);

  const handleDelete = () => {
    const posts = getPosts();
    savePosts(posts.filter((p) => p.id !== id));
    addToast('info', '글이 삭제되었습니다');
    navigate('/board');
  };

  if (!post) return null;

  return (
    <div data-testid="board-detail-page">
      <button
        onClick={() => navigate('/board')}
        className="flex items-center gap-1 text-sm text-gray-500 hover:text-gray-700 mb-4"
        data-testid="post-list-btn"
      >
        <ArrowLeft className="w-4 h-4" />
        목록으로
      </button>

      <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
        {/* Header */}
        <div className="p-6 border-b border-gray-100">
          <div className="flex items-start justify-between">
            <div>
              <div className="flex items-center gap-2 mb-2">
                <span className="text-xs font-medium px-2 py-0.5 rounded-full bg-gray-100 text-gray-600">
                  {categoryLabel[post.category]}
                </span>
                {post.secret && (
                  <span className="flex items-center gap-1 text-xs text-gray-400">
                    <Lock className="w-3 h-3" />
                    비밀글
                  </span>
                )}
              </div>
              <h1 className="text-xl font-bold text-gray-800" data-testid="post-detail-title">{post.title}</h1>
            </div>
            <div className="flex gap-2">
              <button
                onClick={() => navigate(`/board/write/${post.id}`)}
                className="flex items-center gap-1 px-3 py-1.5 text-sm rounded-lg border border-gray-300 text-gray-600 hover:bg-gray-50"
                data-testid="post-edit-btn"
              >
                <Pencil className="w-3.5 h-3.5" />
                수정
              </button>
              <button
                onClick={() => setShowDelete(true)}
                className="flex items-center gap-1 px-3 py-1.5 text-sm rounded-lg border border-red-200 text-red-500 hover:bg-red-50"
                data-testid="post-delete-btn"
              >
                <Trash2 className="w-3.5 h-3.5" />
                삭제
              </button>
            </div>
          </div>
          <div className="flex gap-4 mt-3 text-xs text-gray-400">
            <span data-testid="post-detail-author">작성자: {post.author}</span>
            <span data-testid="post-detail-date">작성일: {post.createdAt}</span>
            <span data-testid="post-detail-views">조회수: {post.views}</span>
          </div>
        </div>

        {/* Content */}
        <div className="p-6 min-h-[200px] text-sm text-gray-700 leading-relaxed whitespace-pre-wrap" data-testid="post-detail-content">
          {post.content}
        </div>
      </div>

      <ConfirmDialog
        open={showDelete}
        message="정말 삭제하시겠습니까?"
        onConfirm={handleDelete}
        onCancel={() => setShowDelete(false)}
      />
    </div>
  );
}
