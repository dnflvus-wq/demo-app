export default function EmbedPage() {
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const form = e.target as HTMLFormElement;
    const data = new FormData(form);
    const name = data.get('name');
    const email = data.get('email');
    alert(`문의가 접수되었습니다.\n이름: ${name}\n이메일: ${email}`);
    form.reset();
  };

  return (
    <div className="max-w-md mx-auto p-6" data-testid="embed-page">
      <h2 className="text-xl font-bold text-gray-800 mb-4" data-testid="embed-title">
        문의하기
      </h2>
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label htmlFor="embed-name" className="block text-sm font-medium text-gray-700 mb-1">
            이름
          </label>
          <input
            id="embed-name"
            name="name"
            type="text"
            placeholder="이름을 입력하세요"
            required
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            data-testid="embed-name"
          />
        </div>
        <div>
          <label htmlFor="embed-email" className="block text-sm font-medium text-gray-700 mb-1">
            이메일
          </label>
          <input
            id="embed-email"
            name="email"
            type="email"
            placeholder="이메일을 입력하세요"
            required
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            data-testid="embed-email"
          />
        </div>
        <div>
          <label htmlFor="embed-category" className="block text-sm font-medium text-gray-700 mb-1">
            카테고리
          </label>
          <select
            id="embed-category"
            name="category"
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            data-testid="embed-category"
          >
            <option value="general">일반 문의</option>
            <option value="support">기술 지원</option>
            <option value="feedback">피드백</option>
          </select>
        </div>
        <div>
          <label htmlFor="embed-message" className="block text-sm font-medium text-gray-700 mb-1">
            메시지
          </label>
          <textarea
            id="embed-message"
            name="message"
            placeholder="메시지를 입력하세요"
            rows={4}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 resize-none"
            data-testid="embed-message"
          />
        </div>
        <button
          id="embed-submit"
          type="submit"
          className="w-full bg-blue-600 text-white py-2 px-4 rounded-lg hover:bg-blue-700 transition-colors font-medium"
          data-testid="embed-submit"
        >
          제출
        </button>
      </form>
    </div>
  );
}
