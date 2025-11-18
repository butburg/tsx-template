import React from 'react';
import { createRoot } from 'react-dom/client';
import ReplaceMeExample from './ReplaceMeExample';
import './styles.css';

createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <ReplaceMeExample />
  </React.StrictMode>
);
