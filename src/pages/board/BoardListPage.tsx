import { useState, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import { Plus, Lock, ChevronLeft, ChevronRight } from 'lucide-react';
import { getPosts } from '../../utils/storage';

const PAGE_SIZE = 10;
const categoryLabel: Record<string, string> = { notice: '공지', free: '자유', question: '질문' };
const categoryColor: Record<string, string> = {
  notice: 'bg-red-100 text-red-600',
  free: 'bg-blue-100 text-blue-600',
  question: 'bg-green-100 text-green-600',
};

export default function BoardListPage() {
  const navigate = useNavigate();
  const posts = getPosts();
  const [page, setPage] = useState(1);

  const sorted = useMemo(() => [...posts].reverse(), [posts]);
  const totalPages = Math.max(1, Math.ceil(sorted.length / PAGE_SIZE));
  const paged = sorted.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);

  return (
    <div data-testid="board-list-page">
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-bold text-gray-800">게시판</h1>
        <button
          onClick={() => navigate('/board/write')}
          className="flex items-center gap-1.5 px-4 py-2 text-sm rounded-lg bg-blue-600 text-white hover:bg-blue-700"
          data-testid="board-write-btn"
        >
          <Plus className="w-4 h-4" />
          글쓰기
        </button>
      </div>

      {/* Table */}
      <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
        <table className="w-full text-sm" data-testid="board-table">
          <thead>
            <tr className="bg-gray-50 border-b border-gray-200">
              <th className="py-3 px-4 text-left font-medium text-gray-500 w-16">번호</th>
              <th className="py-3 px-4 text-left font-medium text-gray-500 w-20">분류</th>
              <th className="py-3 px-4 text-left font-medium text-gray-500">제목</th>
              <th className="py-3 px-4 text-left font-medium text-gray-500 w-24">작성자</th>
              <th className="py-3 px-4 text-left font-medium text-gray-500 w-28">작성일</th>
              <th className="py-3 px-4 text-right font-medium text-gray-500 w-16">조회</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100">
            {paged.length === 0 ? (
              <tr>
                <td colSpan={6} className="py-8 text-center text-gray-400" data-testid="board-empty">
                  아직 작성된 게시글이 없습니다.
                </td>
              </tr>
            ) : (
              paged.map((post, idx) => (
                <tr key={post.id} className="hover:bg-gray-50 cursor-pointer" data-testid={`board-row-${post.id}`}>
                  <td className="py-3 px-4 text-gray-400">{sorted.length - ((page - 1) * PAGE_SIZE + idx)}</td>
                  <td className="py-3 px-4">
                    <span className={`text-xs font-medium px-2 py-0.5 rounded-full ${categoryColor[post.category]}`}>
                      {categoryLabel[post.category]}
                    </span>
                  </td>
                  <td className="py-3 px-4">
                    <button
                      onClick={() => navigate(`/board/${post.id}`)}
                      className="text-gray-800 hover:text-blue-600 flex items-center gap-1"
                      data-testid={`board-title-${post.id}`}
                    >
                      {post.secret && <Lock className="w-3.5 h-3.5 text-gray-400" />}
                      {post.title}
                    </button>
                  </td>
                  <td className="py-3 px-4 text-gray-500">{post.author}</td>
                  <td className="py-3 px-4 text-gray-400">{post.createdAt}</td>
                  <td className="py-3 px-4 text-right text-gray-400">{post.views}</td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="flex items-center justify-center gap-1 mt-6" data-testid="pagination">
          <button
            onClick={() => setPage((p) => Math.max(1, p - 1))}
            disabled={page === 1}
            className="p-2 rounded-lg text-gray-500 hover:bg-gray-100 disabled:opacity-30 disabled:cursor-not-allowed"
            data-testid="page-prev"
          >
            <ChevronLeft className="w-4 h-4" />
          </button>
          {Array.from({ length: totalPages }, (_, i) => i + 1).map((n) => (
            <button
              key={n}
              onClick={() => setPage(n)}
              className={`w-8 h-8 rounded-lg text-sm font-medium ${
                page === n ? 'bg-blue-600 text-white' : 'text-gray-500 hover:bg-gray-100'
              }`}
              data-testid={`page-${n}`}
            >
              {n}
            </button>
          ))}
          <button
            onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
            disabled={page === totalPages}
            className="p-2 rounded-lg text-gray-500 hover:bg-gray-100 disabled:opacity-30 disabled:cursor-not-allowed"
            data-testid="page-next"
          >
            <ChevronRight className="w-4 h-4" />
          </button>
        </div>
      )}
    </div>
  );
}
