import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
  integrations: [
    starlight({
      title: 'mysql-lab',
      social: {},
      sidebar: [
        { label: 'README', link: '/readme/' },
        { label: 'ROADMAP', link: '/roadmap/' },
        { label: 'PITFALLS', link: '/pitfalls/' },
        { label: 'Beginner', autogenerate: { directory: 'beginner' } },
        { label: 'Intermediate', autogenerate: { directory: 'intermediate' } },
        { label: 'Advanced', autogenerate: { directory: 'advanced' } },
      ],
    }),
  ],
});
