// Custom withRouter HOC for React Router v6 compatibility
import { useNavigate, useLocation, useParams } from 'react-router-dom';

export function withRouter(Component) {
  return function ComponentWithRouterProp(props) {
    const navigate = useNavigate();
    const location = useLocation();
    const params = useParams();

    return (
      <Component
        {...props}
        router={{ navigate, location, params }}
        // For backward compatibility, also provide individual props
        navigate={navigate}
        location={location}
        match={{ params }}
      />
    );
  };
}
