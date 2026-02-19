import { NavLink, Outlet } from 'react-router-dom';
import { Home, CheckSquare, FileText } from 'lucide-react';

const navItems = [
  { to: '/', label: 'Home', icon: Home, testId: 'nav-home' },
  { to: '/todo', label: 'Todo', icon: CheckSquare, testId: 'nav-todo' },
  { to: '/board', label: 'Board', icon: FileText, testId: 'nav-board' },
];

export default function Layout() {
  return (
    <div className="min-h-screen flex flex-col">
      <header className="bg-white border-b border-gray-200 shadow-sm" data-testid="header">
        <div className="max-w-4xl mx-auto px-4 h-14 flex items-center justify-between">
          <NavLink to="/" className="text-xl font-bold text-blue-600" data-testid="logo">
            DemoApp
          </NavLink>
          <nav className="flex gap-1" data-testid="nav">
            {navItems.map(({ to, label, icon: Icon, testId }) => (
              <NavLink
                key={to}
                to={to}
                end={to === '/'}
                data-testid={testId}
                className={({ isActive }) =>
                  `flex items-center gap-1.5 px-3 py-2 rounded-lg text-sm font-medium transition-colors ${
                    isActive ? 'bg-blue-50 text-blue-600' : 'text-gray-600 hover:bg-gray-50'
                  }`
                }
              >
                <Icon className="w-4 h-4" />
                {label}
              </NavLink>
            ))}
          </nav>
        </div>
      </header>

      <main className="flex-1 max-w-4xl mx-auto w-full px-4 py-6">
        <Outlet />
      </main>

      <footer className="border-t border-gray-200 py-4 text-center text-xs text-gray-400" data-testid="footer">
        DemoApp v1.0 - GENQ Test Target
      </footer>
    </div>
  );
}
