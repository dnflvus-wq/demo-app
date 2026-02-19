import { useNavigate } from 'react-router-dom';
import { ArrowRight, CheckSquare, FileText } from 'lucide-react';
import { getTodos, getPosts } from '../utils/storage';

export default function HomePage() {
  const navigate = useNavigate();
  const todos = getTodos();
  const posts = getPosts();

  const totalTodos = todos.length;
  const completedTodos = todos.filter((t) => t.completed).length;
  const activeTodos = totalTodos - completedTodos;
  const recentPosts = posts.slice(-3).reverse();

  return (
    <div data-testid="home-page">
      <h1 className="text-2xl font-bold text-gray-800 mb-6" data-testid="page-title">
        DemoApp 대시보드
      </h1>

      {/* Stats */}
      <div className="grid grid-cols-3 gap-4 mb-8">
        <div className="bg-white rounded-xl border border-gray-200 p-5 text-center" data-testid="stat-total">
          <div className="text-3xl font-bold text-gray-800">{totalTodos}</div>
          <div className="text-sm text-gray-500 mt-1">전체 Todo</div>
        </div>
        <div className="bg-white rounded-xl border border-gray-200 p-5 text-center" data-testid="stat-active">
          <div className="text-3xl font-bold text-blue-600">{activeTodos}</div>
          <div className="text-sm text-gray-500 mt-1">진행중</div>
        </div>
        <div className="bg-white rounded-xl border border-gray-200 p-5 text-center" data-testid="stat-completed">
          <div className="text-3xl font-bold text-green-600">{completedTodos}</div>
          <div className="text-sm text-gray-500 mt-1">완료</div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="grid grid-cols-2 gap-4 mb-8">
        <button
          onClick={() => navigate('/todo')}
          className="flex items-center gap-3 bg-blue-600 text-white rounded-xl p-5 hover:bg-blue-700 transition-colors"
          data-testid="btn-start"
        >
          <CheckSquare className="w-6 h-6" />
          <div className="text-left">
            <div className="font-semibold">Todo 시작하기</div>
            <div className="text-sm text-blue-100">할 일을 관리해보세요</div>
          </div>
          <ArrowRight className="w-5 h-5 ml-auto" />
        </button>
        <button
          onClick={() => navigate('/board')}
          className="flex items-center gap-3 bg-white border border-gray-200 rounded-xl p-5 hover:bg-gray-50 transition-colors"
          data-testid="btn-board"
        >
          <FileText className="w-6 h-6 text-gray-600" />
          <div className="text-left">
            <div className="font-semibold text-gray-800">게시판 가기</div>
            <div className="text-sm text-gray-500">글을 읽고 작성해보세요</div>
          </div>
          <ArrowRight className="w-5 h-5 ml-auto text-gray-400" />
        </button>
      </div>

      {/* Recent Posts */}
      <div className="bg-white rounded-xl border border-gray-200 p-5">
        <h2 className="text-lg font-semibold text-gray-800 mb-4" data-testid="recent-posts-title">최근 게시글</h2>
        {recentPosts.length === 0 ? (
          <p className="text-gray-400 text-sm">아직 게시글이 없습니다.</p>
        ) : (
          <ul className="divide-y divide-gray-100">
            {recentPosts.map((post) => (
              <li key={post.id} className="py-3 flex justify-between items-center">
                <button
                  onClick={() => navigate(`/board/${post.id}`)}
                  className="text-sm text-gray-700 hover:text-blue-600 text-left"
                  data-testid={`recent-post-${post.id}`}
                >
                  {post.secret ? '🔒 ' : ''}{post.title}
                </button>
                <span className="text-xs text-gray-400">{post.createdAt}</span>
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  );
}
