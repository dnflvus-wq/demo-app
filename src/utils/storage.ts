import type { Todo, Post } from '../types';

const TODOS_KEY = 'demo-app-todos';
const POSTS_KEY = 'demo-app-posts';

// --- Todo ---
export function getTodos(): Todo[] {
  const raw = localStorage.getItem(TODOS_KEY);
  return raw ? JSON.parse(raw) : [];
}

export function saveTodos(todos: Todo[]) {
  localStorage.setItem(TODOS_KEY, JSON.stringify(todos));
}

// --- Post ---
export function getPosts(): Post[] {
  const raw = localStorage.getItem(POSTS_KEY);
  if (raw) return JSON.parse(raw);
  // seed sample data
  const samples: Post[] = [
    { id: '1', title: '공지사항입니다', author: '관리자', content: '이 게시판은 DemoApp의 공지사항 게시판입니다. 테스트케이스 생성 검증을 위해 만들어졌습니다.', category: 'notice', secret: false, views: 12, createdAt: '2026-02-10' },
    { id: '2', title: '자유게시판 첫 글', author: '홍길동', content: '안녕하세요! 자유게시판 첫 글입니다. 자유롭게 글을 작성할 수 있습니다.', category: 'free', secret: false, views: 5, createdAt: '2026-02-11' },
    { id: '3', title: 'React 질문있어요', author: '김개발', content: 'React에서 useState와 useReducer의 차이점이 무엇인가요? 상태가 복잡해지면 어떤 걸 쓰는 게 좋을까요?', category: 'question', secret: false, views: 8, createdAt: '2026-02-12' },
    { id: '4', title: '비밀 글 테스트', author: '이비밀', content: '이 글은 비밀글로 작성되었습니다. 비밀글 기능이 정상적으로 동작하는지 확인하는 테스트 글입니다.', category: 'free', secret: true, views: 2, createdAt: '2026-02-13' },
    { id: '5', title: 'Vite 설정 방법', author: '박프론트', content: 'Vite를 사용한 React 프로젝트 설정 방법을 정리했습니다. npm create vite@latest 명령어로 시작하면 됩니다.', category: 'question', secret: false, views: 15, createdAt: '2026-02-14' },
    { id: '6', title: '두번째 공지', author: '관리자', content: '서비스 점검 안내입니다. 2026년 2월 20일 새벽 2시부터 4시까지 서버 점검이 있을 예정입니다.', category: 'notice', secret: false, views: 20, createdAt: '2026-02-15' },
  ];
  localStorage.setItem(POSTS_KEY, JSON.stringify(samples));
  return samples;
}

export function savePosts(posts: Post[]) {
  localStorage.setItem(POSTS_KEY, JSON.stringify(posts));
}

export function generateId(): string {
  return Date.now().toString(36) + Math.random().toString(36).slice(2, 7);
}

export function formatDate(date: Date): string {
  return date.toISOString().slice(0, 10);
}
